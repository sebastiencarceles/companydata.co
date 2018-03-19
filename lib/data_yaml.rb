# frozen_string_literal: true

module DataYaml
  class << self
    def dump(outdir, cls, per_page: 100000, gzip: true)
      Rails.logger.info "Dump entries of #{cls} into #{outdir}"
      prepare_output_directory(outdir, cls)
      page = 1
      scope = scope(cls, page, per_page)
      while scope.any? do
        filepath = filepath(outdir, cls, page, gzip: gzip)
        Rails.logger.info "Dump into #{filepath}"

        if gzip
          File.open(filepath, "wb") do |file|
            Zlib::GzipWriter.wrap(file) do |gz|
              write_into(gz, scope)
            end
          end
        else
          File.open(filepath, "w") do |file|
            write_into(file, scope)
          end
        end

        page += 1
        scope = scope(cls, page, per_page)
      end
    end

    def load(indir, cls, gzip: true, on_duplicate_key_ignore: true)
      Rails.logger.info "Load entries of #{cls} from #{indir}"
      page = 1
      filepath = filepath(indir, cls, page, gzip: gzip)
      while File.exists?(filepath) do
        Rails.logger.info "Load from #{filepath}"

        if gzip
          File.open(filepath, "rb") do |file|
            Zlib::GzipReader.wrap(file) do |gz|
              read_from(gz, cls, on_duplicate_key_ignore)
            end
          end
        else
          File.open(filepath, "r") do |file|
            read_from(file, cls, on_duplicate_key_ignore)
          end
        end

        page += 1
        filepath = filepath(indir, cls, page, gzip: gzip)
      end
    end

    def load_from_s3(indir_url, cls, gzip: true, on_duplicate_key_ignore: true)
      Rails.logger.info "Load entries from AWS S3 #{indir_url}"
      base_url = base_url(indir_url, cls)
      page = 1
      fileurl = fileurl(base_url, page, gzip: gzip)
      while remote_file_exists?(fileurl) do
        Rails.logger.info "Load from #{fileurl}"

        if gzip
          open(fileurl) do |file|
            Zlib::GzipReader.wrap(file) do |gz|
              read_from(gz, cls, on_duplicate_key_ignore)
            end
          end
        else
          open(fileurl) do |file|
            read_from(file, cls, on_duplicate_key_ignore)
          end
        end

        page += 1
        fileurl = fileurl(base_url, page, gzip: gzip)
      end
    end

    private

      def write_into(file, scope)
        scope.each do |entity|
          file.write(entity.attributes.to_yaml)
        end
      end

      def read_from(file, cls, on_duplicate_key_ignore)
        entries = []
        YAML.load_stream(file) do |data|
          entries << data
          if entries.size >= 10000
            Rails.logger.info "Import #{entries.count} entries"
            cls.import(entries, on_duplicate_key_ignore: on_duplicate_key_ignore)
            entries.clear
          end
        end
        Rails.logger.info "Import #{entries.count} entries"
        cls.import(entries, on_duplicate_key_ignore: on_duplicate_key_ignore)
      end

      def scope(cls, page, per_page)
        cls.order(:id).page(page).per(per_page)
      end

      def prepare_output_directory(outdir, cls)
        Dir.mkdir(dirpath(outdir, cls)) unless Dir.exist?(dirpath(outdir, cls))
      end

      def dirpath(dir, cls) # TODO rename
        File.join(dir, cls.name.tableize)
      end

      def filepath(dir, cls, page, gzip) # TODO rename
        additional_extension = ".gz" if gzip
        File.join(dirpath(dir, cls), "#{rjust(page)}.yml#{additional_extension}")
      end

      def rjust(page)
        page.to_s.rjust(4, "0")
      end

      def base_url(indir_url, cls) # TODO fault tolerance
        [indir_url, "/", cls.name.tableize].join("")
      end

      def fileurl(base_url, page, gzip: false) # TODO rename
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
