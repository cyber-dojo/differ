
module DeltaMaker # mix-in

  module_function

  # make_delta finds out which files are :new, :unchanged, :changed, or :deleted.
  # It ensures files deleted in the browser are correspondingly deleted under katas/
  # It also allows unchanged files to *not* be (re)saved.

  def make_delta(was, now)
    result = {
      new: now.keys - was.keys,
      unchanged:[],
      changed:[],
      deleted:[]
    }
    was.each do |filename, content|
      if now[filename] == content
        result[:unchanged] << filename
      elsif !now[filename].nil?
        result[:changed] << filename
      else
        result[:deleted] << filename
      end
    end
    result
  end

end
