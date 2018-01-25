# frozen_string_literal: true

module DataYaml
  class << self
    def dump(outdir, cls, page = 1, per_page = 10000, except = [])
      Rails.logger.info "Dump entries of #{cls} into #{outdir}"
      prepare_output_directory(outdir, cls)
      while scope(cls, page, per_page).any? do
        Rails.logger.info "Dump into #{filepath(outdir, cls, page)}"
        File.open(filepath(outdir, cls, page), "w") do |file|
          scope(cls, page, per_page).each do |entity|
            file.write(entity.attributes.except(except).to_yaml)
          end
        end
        page += 1
      end
    end

    def load(indir, cls, page = 1, on_duplicate_key_ignore = true)
      Rails.logger.info "Load entries of #{cls} from #{indir}"
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

    private

      def scope(cls, page, per_page)
        cls.order(:id).page(page).per(per_page)
      end

      def prepare_output_directory(outdir, cls)
        Dir.mkdir(dirpath(outdir, cls)) unless Dir.exist?(dirpath(outdir, cls))
      end

      def dirpath(dir, cls)
        File.join(dir, cls.name.tableize)
      end

      def filepath(dir, cls, page)
        File.join(dirpath(dir, cls), "#{rjust(page)}.yml")
      end

      def rjust(page)
        page.to_s.rjust(4, "0")
      end
  end
end
