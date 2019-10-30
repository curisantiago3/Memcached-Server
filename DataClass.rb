
class DataClass
  def initialize(data,data_b,id)
    @date_out = Time.now.to_i + data[2].to_i
    if (data[2].to_i==0)
      @date_out = Time.now.to_i + 60*60*24*30 #30 days from now
    end
    @data = data
    @data_block = data_b
    @id = id
  end

  def setData(new_data)
    @data = new_data
  end

  def setDateOut(new_expire)
    @date_out = new_expire
  end

  def setData_block(data_b)
    @data_block = data_b
    @data[3] = data_b.length
  end

  def getData()
    return @data
  end

  def getId()
    return @id
  end

  def getData_block()
    return @data_block
  end

  def isExpired()
    return (@date_out <= Time.now.to_i)
  end

end
