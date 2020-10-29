# frozen_string_literal: true

module GitDiffLib # mix-in

  def empty?(diff)
    diff[:lines] === []
  end

  def line_split(src)
    if src === ''
      ['']
    else
      src.split("\n")
    end
  end

  def unchanged_rename?(old_filename, old_files, new_filename, new_files)
    old_files[old_filename] === new_files[new_filename]
  end

  def new_file?(diff)
    diff[:old_filename].nil?
  end

  def deleted_file?(diff)
    diff[:new_filename].nil?
  end

  #def renamed_file?(diff)
  #  diff[:new_filename] != diff[:old_filename]
  #end

  def all(type, lines)
    lines.collect.each.with_index(1) do |line,number|
      { type:type, line:line, number:number }
    end
  end

end
