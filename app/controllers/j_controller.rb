require 'ncbi'

class JController < ApplicationController

  def get_paper_info_from_ncbi
    #~ re = {:OK=>true}
    #~ re = {:OK=>false, :Error=>:Net}
    #~ re = {:OK=>false, :Error=>:Parse}
    @existed_paper = Paper.find_by_identifier(params[:pmid])
    if @existed_paper != nil
      render :action=>'existed_paper' 
      return
    end
    re = _get_from_ncbi(params[:pmid])
    if (!re[:OK])
      render :text=>"<div class='errorExplanation' id='errorExplanation'><ul><li>Connection to NCBI fails</li></ul></div>" if (re[:Error]==:Net)
      render :text=>"<div class='errorExplanation' id='errorExplanation'><ul><li>Parsing Exception occurs</li></ul></div>" if (re[:Error]==:Parse)
    else
      @paper = Paper.new
      @paper.title = re[:title]
      @paper.source = re[:source]
      @paper.publish_time =  re[:publishedtime]
      @paper.abstract = re[:abstract]
      @paper.identifier = re[:pmid]
      
      @authors = re[:authors]==nil ? [] : re[:authors]
    end
  end
  
  private
  def _get_from_ncbi(pmid)
    return NCBIGetter.new().get(pmid)
  end
end
