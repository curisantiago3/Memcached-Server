require_relative 'DataClass'

class Data_handler
  def initialize()
    @datas = Hash.new
    @id=1
  end


##########SETTERS##########
  def set(new_key,data,data_block)
    datas = DataClass.new(data,data_block,@id)
    @datas[new_key]=datas
    @id = @id + 1
    return "STORED"
  end

  def add(key,data,data_block)
    if(@datas[key] == nil)
      @datas[key] = DataClass.new(data,data_block,@id)
      @id = @id + 1
      return "STORED"
    end
    return "NOT_STORED"
  end

  def replace(key,data,data_block)
    if (@datas[key]!=nil)
      @datas[key]=DataClass.new(data,data_block,@id)
      @id = @id + 1
      return "STORED"
    end
    return "NOT_STORED"
  end

  def append(key,data,data_block)
    if (@datas[key]!=nil)
         @datas[key].setData_block(@datas[key].getData_block().concat(data_block))
       return "STORED"
     end
     return "NOT_STORED"
  end

  def prepend(key,data,data_block)
    if (@datas[key]!=nil)
       @datas[key].setData_block(data_block.concat(@datas[key].getData_block()))
       return "STORED"
     end
     return "NOT_STORED"
  end

  def cas(key,data,data_block)
    if(@datas[key] == nil) && (data[3] == @datas[key].getId)
      return self.set(key,data,data_block)
    end
  end

  ##########GETTERS##########
  def get(key)
    if (@datas[key]!=nil)
      return @datas[key].getData().reject.with_index { |_el, index| index == 1 }.join(' ')
    end
  return nil
  end

  def getBlock(key)
    if (@datas[key]!=nil)
      return @datas[key].getData_block()
    end
    return nil
  end

  def gets(key)
    if (@datas[key]!=nil)
      return self.get(key).concat("  #{@datas[key].getId()}")
    end
    return nil
  end

  ########DELETE EXPIRED KEYS##########
  def deleteExpired()
        @datas.delete_if{|key| @datas[key].isExpired()}
  end

end
