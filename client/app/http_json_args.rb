class HttpJsonArgs

  def get(path)
    case path
    when '/ready'   then ['ready'  ,[]]
    else
      raise 'unknown path'
    end
  end

end
