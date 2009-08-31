class Ar2yamlController < ApplicationController

  FIXTURES_DIR="test/fixtures/"
  
  #### desc ####
  # this is ruby on rails controller to generate data to yaml files
  # just type /ar2yaml/dump/{model_name} on your browser


  def dump
    response.headers["Content-Type"]="text/plain"
    @res=""
    if params[:id]=="survey"
      dump_models(SURVEYS_MODELS)
    elsif params[:id]=="quizme"
      dump_models(QUIZME_MODELS)  
    else
      @res << "#### "+params[:id].camelize+" ### \n\n"+generate(params[:id])
    end
    render :action=>"index",:layout => false
  end


  #private
  def dump_models(models)  
    @res="" if @res.nil?
    models.each do |list|
      @res << "#### "+list.camelize+" ### \n\n"+generate(list)      
    end
  end
  
  def generate(model)
    klass=model.classify.constantize

    datas=klass.find(:all)
    res=''
    datas.each_with_index do |data,iterator|
      i=iterator+1
      res << model.camelize+i.to_s+": \n"
      for column in klass.columns
        res << "  "+column.name+": "+parsing_all(data.send(column.name)).to_s+"\n"        
      end
      res << "\n" if datas.last
    end
    open(FIXTURES_DIR+model.tableize+".yml",'w') { |f| f << res }
    return res
  end 

  def parsing_all(data)
    need_dq(data)
    parsing_time(data)  
  end 

  ### need double quote ?
  def need_dq(data)
    
    if data=="Yes" || data=="No" || data.class.to_s=="String"
      data='"'+data+'"'   
    end
    return data  
  end

  def parsing_time(data)
    if data.class.to_s=="Time"
      data=data.strftime("%Y-%m-%d %H:%M:%S")
    else
      return data
    end
  end
    
end
