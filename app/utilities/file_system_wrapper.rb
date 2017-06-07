module Hacienda
  class FileSystemWrapper

    def glob(pattern)
      Dir.glob(pattern)
    end

    def read(file_path)
      IO.read(file_path)
    end

    def basename(filename)
      File.basename(filename)
    end

    def extname(path)
      File.extname(path)
    end

    def exists?(filename)
      File.exists?(filename)
    end

    def find_all_ids(data_dir, path)
      base_path = "#{data_dir}/#{path}/"
      glob("#{base_path}**/*.json").collect {|filename| relative_path(filename, base_path)}
    end
    
    def relative_path(filename, base_path)
      filename.slice!(base_path)
      filename.chomp(extname(filename))
    end
    
    def full_path_of_referenced_file(data_filename, filename)
      File.join(File.dirname(data_filename), filename)
    end

  end
end
