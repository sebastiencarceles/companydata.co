# frozen_string_literal: true

module DataYaml
  class << self
    def dump(outdir, cls, per_page: 100000, gzip: true)
      Rails.logger.info "Dump entries of #{cls} into #{outdir}"
      prepare_output_directory(outdir, cls)
      page = 1
      while scope(cls, page, per_page).any? do
        filepath = filepath(outdir, cls, page, gzip: gzip)
        Rails.logger.info "Dump into #{filepath}"
        if gzip
          File.open(filepath, "wb") do |file|
            Zlib::GzipWriter.wrap(file) do |gz|
              write_into(gz, scope(cls, page, per_page))
            end
          end
        else
          File.open(filepath, "w") do |file|
            write_into(file, scope(cls, page, per_page))
          end
        end
        page += 1
      end
    end

    def load(indir, cls, on_duplicate_key_ignore: true)
      Rails.logger.info "Load entries of #{cls} from #{indir}"
      page = 1
      while File.exists?(filepath(indir, cls, page)) do
        Rails.logger.info "Load from #{filepath(indir, cls, page)}"
        entries = []
        YAML.load_stream(File.read(filepath(indir, cls, page))) do |data|
          entries << data
          if entries.size >= 10000
            Rails.logger.info "Import #{entries.count} entries"
            cls.import entries, on_duplicate_key_ignore: on_duplicate_key_ignore
            entries.clear
          end
        end
        Rails.logger.info "Import #{entries.count} entries"
        cls.import entries, on_duplicate_key_ignore: on_duplicate_key_ignore
        page += 1
      end
    end

    def load_from_s3(indir_url, cls, on_duplicate_key_error: true)
      Rails.logger.info "Load companies from AWS S3 #{indir_url}"
      base_url = base_url(indir_url, cls)

      # File.open("data.tar.gz", "rb") do |file|
      #   Zlib::GzipReader.wrap(file) do |gz|
      #     Gem::Package::TarReader.new(gz) do |tar|
      #       tar.each { |entry| puts entry.full_name }
      #     end
      #   end
      # end


      while remote_file_exists?(fileurl(base_url, page)) do
        Rails.logger.info "Load from #{fileurl(base_url, page)}"
        entries = []
        open(fileurl(base_url, page)) do |file|
          YAML.load_stream(file) do |data|
            entries << data
            if entries.size >= 10000
              Rails.logger.info "Import #{entries.count} entries"
              cls.import entries, on_duplicate_key_ignore: on_duplicate_key_ignore
              entries.clear
            end
          end
        end
        Rails.logger.info "Import #{entries.count} entries"
        cls.import entries, on_duplicate_key_ignore: on_duplicate_key_ignore
        page += 1
      end
    end

    private

      def write_into(file, scope)
        scope.each do |entity|
          file.write(entity.attributes.to_yaml)
        end
      end

      def scope(cls, page, per_page)
        cls.order(:id).page(page).per(per_page)
      end

      def prepare_output_directory(outdir, cls)
        Dir.mkdir(dirpath(outdir, cls)) unless Dir.exist?(dirpath(outdir, cls))
      end

      def dirpath(dir, cls)
        File.join(dir, cls.name.tableize)
      end

      def filepath(dir, cls, page, gzip: false)
        additional_extension = ".gz" if gzip
        File.join(dirpath(dir, cls), "#{rjust(page)}.yml#{additional_extension}")
      end

      def rjust(page)
        page.to_s.rjust(4, "0")
      end

      def base_url(indir_url, cls)
        [indir_url, "/", cls.name.tableize].join("/")
      end

      def fileurl(base_url, page, gzip: false)
        additional_extension = ".gz" if gzip
        [base_url, "#{rjust(page)}.yml#{additional_extension}"].join("/")
      end

      def remote_file_exists?(uri)
        url = URI.parse(uri)
        request = Net::HTTP.new(url.host, url.port)
        request.use_ssl = true
        request.request_head(url.path).code == "200"
      end
  end
end
