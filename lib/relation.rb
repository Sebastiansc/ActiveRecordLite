class Criteria
  def criteria
      @criteria ||= {:conditions => {}}
    end



  def where(args)
      criteria[:conditions].merge!(args)
    end
end
