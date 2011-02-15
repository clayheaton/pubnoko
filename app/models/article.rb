class Article < ActiveRecord::Base
  require 'open-uri'
  
  attr_accessible :pubmedlink, 
                  :article_title, 
                  :abstract, 
                  :authors, 
                  :affiliations, 
                  :pubdate, 
                  :pubmedid, 
                  :journal_id, 
                  :journal_volume, 
                  :journal_issue, 
                  :journal_pages,
                  :fetched

  belongs_to :journal
  
  validates_uniqueness_of :article_title
  validates_uniqueness_of :pubmedid
  validates_uniqueness_of :pubmedlink
  
  before_create :make_pubmedid
  before_update :make_pubmedid
  
  def citation
    cit = ""
    if self.journal_id != nil && self.journal_id > 0
      cit += self.journal.best_name + ". " + self.pubdate.year.to_s + " " + self.pubdate.strftime("%b")
    end
    if self.journal_volume != nil && self.journal_volume.length > 0
      cit += "; " + self.journal_volume
    end
    if self.journal_issue != nil && self.journal_issue.length > 0
      cit += "(" + self.journal_issue + ")"
    end
    if self.journal_pages != nil && self.journal_pages.length > 0
      cit += ": " + self.journal_pages
    end
      return cit
  end
  
  private
  
  def make_pubmedid
    if self.pubmedlink != nil && self.pubmedlink.length > 0 && self.fetched == false
      regex = Regexp.new(/[0-9]{4,10}/)
      matchdata = regex.match(self.pubmedlink)
      self.pubmedid = matchdata[0]
      pull_pubmed_data(matchdata[0])
      self.fetched = true
    end
  end
  
  def pull_pubmed_data(theID)
    @doc = Nokogiri::XML(open("http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=" + theID.to_s + "&retmode=xml").read)
    
    # The title and abstract
    self.article_title = @doc.xpath("//ArticleTitle").collect(&:text)[0]
    self.abstract = @doc.xpath("//AbstractText").collect(&:text)[0]
    
    # Setting up the authors
    first_names = @doc.xpath("//ForeName").collect(&:text)
    last_names = @doc.xpath("//LastName").collect(&:text)
    full_names = []
    
    i = 0
    last_names.length.times do
      the_name = first_names[i].to_s + " " + last_names[i].to_s
      full_names.push the_name
      i += 1
    end
    self.authors = full_names.join(", ")
    
    # Affiliations
    self.affiliations = @doc.xpath("//Affiliation").collect(&:text)[0]
    
    # Publication Date - Check if the complete date is at the top. If not use the pub med date.
    theyear = @doc.xpath("//PubDate/Year").collect(&:text)
    theyear = theyear[0]
    themonth = @doc.xpath("//PubDate/Month").collect(&:text)
    themonth = themonth[0]
    theday = @doc.xpath("//PubDate/Day").collect(&:text)
    
    if theyear.nil? || themonth.nil? || theday.nil? || theyear.length == 0 || themonth.length == 0 || theday.length == 0
      
      theyear = @doc.xpath("//PubMedPubDate[@PubStatus='pubmed']/Year").collect(&:text)
      theyear = theyear[0]
      
      themonth = @doc.xpath("//PubMedPubDate[@PubStatus='pubmed']/Month").collect(&:text)
      themonth = themonth[0].to_i
        month_done = 1
      if themonth < 10
        themonth = "0" + themonth.to_s
        month_done = 1
      end
      
      theday = @doc.xpath("//PubMedPubDate[@PubStatus='pubmed']/Day").collect(&:text)
    end
    
    if month_done != 1
    
      themonth = case themonth || "01"
        when "Jan"  then "01"
        when "Feb"  then "02"
        when "Mar"  then "03"
        when "Apr"  then "04"
        when "May"  then "05"
        when "Jun"  then "06"
        when "Jul"  then "07"
        when "Aug"  then "08"
        when "Sep"  then "09"
        when "Oct"  then "10"
        when "Nov"  then "11"
        when "Dec"  then "12"
      end
    
    end
    
    if theday.length == 0
      theday = "01"
    elsif theday[0].to_i < 10
      theday = "0" + theday[0].to_s
    else
      theday = theday[0].to_s
    end
    
    thedate = theyear.to_s + "-" + themonth.to_s + "-" + theday.to_s
    puts "thedate: " + thedate.to_s
    self.pubdate = Date.new(theyear.to_i, themonth.to_i, theday.to_i)
    
    # Either referencing the proper journal or creating a new one
    thejournal = @doc.xpath("//Journal/Title").collect(&:text)
    thejournal = thejournal[0]
    
    theshortname = @doc.xpath("//MedlineTA").collect(&:text)
    if theshortname.length == 0
      theshortname = ""
    else
      theshortname = theshortname[0]
    end
    
    thejournalid = Journal.find(:first, :conditions => ['lower(name) = ?', thejournal.downcase])
    
    if !thejournalid.nil?
      self.journal_id = thejournalid.id
    else
      @journal = Journal.new(:name => thejournal.to_s, :short_name => theshortname.to_s)
      @journal.save
      thenewjournal = Journal.find(:first, :order => 'created_at DESC')
      self.journal_id = thenewjournal.id
    end
    
    # Save the volume, issue, and pages
    thevolume = @doc.xpath("//JournalIssue/Volume").collect(&:text)
    thevolume = thevolume[0].to_s if thevolume.length > 0
    self.journal_volume = thevolume if thevolume.length > 0
    
    theissue = @doc.xpath("//JournalIssue/Issue").collect(&:text)
    theissue = theissue[0].to_s if theissue.length > 0
    self.journal_issue = theissue if theissue.length > 0
    
    thepag = @doc.xpath("//Pagination/MedlinePgn").collect(&:text)
    thepag = thepag[0].to_s if thepag.length > 0
    self.journal_pages = thepag if thepag.length > 0
    
  end
  
end

