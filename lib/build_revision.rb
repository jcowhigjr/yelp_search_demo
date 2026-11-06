# Only a build-generated artifact identifies the deployed code.
module BuildRevision
  PATH = File.expand_path('../config/build_revision', __dir__).freeze
  SHA = /\A[0-9a-f]{40}\z/

  def self.current(path: PATH)
    revision = File.read(path).strip
    revision.match?(SHA) ? revision : 'unknown'
  rescue Errno::ENOENT
    'unknown'
  end

  def self.capture(source, path: PATH)
    revision = source.to_s.strip
    raise ArgumentError, 'Invalid build source revision' unless revision.empty? || revision.match?(SHA)

    # Overwrite any stale artifact even on builds without source metadata.
    File.write(path, "#{revision.empty? ? 'unknown' : revision}\n")
  end
end
