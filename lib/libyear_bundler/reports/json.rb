require 'json'
require 'libyear_bundler/reports/base'

module LibyearBundler
  module Reports
    # Responsible for generating data from the `::LibyearBundler::Models` in JSON format.
    # Should only be concerned with presentation, nothing else.
    class JSON < Base
      def write
        data = {
          gems: to_h[:gems].map { |gem| gem_info(gem) },
          ruby: gem_info(@ruby),
        }
        data[:sum_libyears] = to_h[:sum_libyears].truncate(1) if @options.libyears?
        data[:sum_seq_delta] = to_h[:sum_seq_delta].truncate(1) if @options.releases?
        if @options.versions?
          data[:sum_major_version] = to_h[:sum_major_version].truncate(1)
          data[:sum_minor_version] = to_h[:sum_minor_version].truncate(1)
          data[:sum_patch_version] = to_h[:sum_patch_version].truncate(1)
        end

        @io.puts ::JSON.pretty_generate(data)
      end

      private

      def gem_info(gem_or_ruby)
        info = {
          name: gem_or_ruby.name,
          installed_version: gem_or_ruby.installed_version.to_s,
          installed_version_release_date: gem_or_ruby.installed_version_release_date,
          newest_version: gem_or_ruby.newest_version.to_s,
          newest_version_release_date: gem_or_ruby.newest_version_release_date,
        }

        info[:releases] = gem_or_ruby.version_sequence_delta if @options.releases?
        info[:versions] = %i[major minor patch].zip(gem_or_ruby.version_number_delta).to_h if @options.versions?
        info[:libyears] = gem_or_ruby.libyears.truncate(1) if @options.libyears?

        info
      end
    end
  end
end
