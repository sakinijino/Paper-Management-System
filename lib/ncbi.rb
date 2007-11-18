require "date"
require "rexml/document"
require "http-access2"

class Getter
  def get(id)
    return {:OK=>true}
  end
end

class NCBIGetter < Getter
  def get(id)
    re = __getNCBIContent(id)
    return {:OK=>false, :Error=>:Net} if !re[:OK]
    return self.get_local(re[:content])
  end
  
  def get_local(content)
    re = __parseNCBI(content)
    return {:OK=>false, :Error=>:Parse} if !re[:OK]
    return re
  end
  
  private
  def __getNCBIContent(pmid)
    prefix = "http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&term="
    suffix = "[uid]"
    client = HTTPClient.new()
    begin
      message = client.get(prefix+pmid+suffix)
    rescue
      return {:OK=>false};
    end
    response_status_code = message.header.response_status_code
    if (response_status_code!=200) then {:OK=>false} end
    return {:OK=>true, :content=>message.body.content}
  end

  def __parseNCBI(content)
    begin
      doc = REXML::Document.new content
    rescue
      return {:OK=>false};
    end
    arr = doc.elements.to_a("//dl").find_all {|n| n.attribute('class').to_s == 'PubmedArticle'}
    #arr = doc.elements.to_a("//dl[@class='PubmedArticle']")
    if (arr.length<=0) then return {:OK=>false} end
    article = arr[0]
    begin
      article = REXML::Document.new article.to_s
    rescue
      return {:OK=>false};
    end
    
    publishedtime = article.elements["//span[@class='ti']"]
    source = article.elements["//span[@class='ti']/span/a"]
    title = article.elements["//dd[@class='abstract']/h2"]
    authors = article.elements.to_a("//dd[@class='abstract']/div[@class='authors']/a/b")
    abstract = article.elements["//dd[@class='abstract']/p[@class='abstract']"]
    pmid = article.elements["//dd[@class='abstract']/p[@class='pmid']"]
    
    publishedtime = publishedtime!=nil ? Date.parse(publishedtime.text.split(';')[0]) : nil
    source = source!=nil ? source.text : nil
    title = title!=nil ? title.text : nil
    authors = authors!=nil ? authors.map {|n| n.text} : nil
    abstract = abstract!=nil ? abstract.text : nil
    pmid = pmid!=nil ? pmid.text.match(/\d{8}/).to_s : nil
    return {:OK=>true, :publishedtime=>publishedtime, :source=>source, :title=>title, :authors => authors, :abstract => abstract, :pmid=>pmid}
  end
end