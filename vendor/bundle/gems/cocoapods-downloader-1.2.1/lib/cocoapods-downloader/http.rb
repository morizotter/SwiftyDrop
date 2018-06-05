require 'cocoapods-downloader/remote_file'

module Pod
  module Downloader
    class Http < RemoteFile
      private

      executable :curl

      def download_file(full_filename)
        curl! '-f', '-L', '-o', full_filename, url, '--create-dirs', '--netrc-optional', '--retry', '2'
      end
    end
  end
end
