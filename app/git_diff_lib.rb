# frozen_string_literal: true

module GitDiffLib # mix-in

  def type_of(diff)
    if created_file?(diff)
      return :created
    elsif deleted_file?(diff)
      return :deleted
    elsif renamed_file?(diff)
      return :renamed
    else # changed_file?(diff)
      return :changed
    end
  end

  def created_file?(diff)
    diff[:old_filename].nil? # !diff[:new_filename].nil?
  end

  def deleted_file?(diff)
    diff[:new_filename].nil? # !diff[:old_filename].nil?
  end

  def renamed_file?(diff)
    diff[:old_filename] != diff[:new_filename] # && !new_file?(diff) && !deleted_file?(diff)
  end

  #def changed_file?(diff)
  #  diff[:old_filename] === diff[:new_filename]
  #end

  def empty?(diff)
    diff[:lines] === []
  end

  # - - - - - - - - - - - - - - - - - -

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

  def all(type, lines)
    lines.collect.each.with_index(1) do |line,number|
      { type:type, line:line, number:number }
    end
  end

end
