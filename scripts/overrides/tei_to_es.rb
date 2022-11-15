class TeiToEs

  ################
  #    XPATHS    #
  ################

  # in the below example, the xpath for "person" is altered
  def override_xpaths
    xpaths = {}
    # xpaths["date"] = "/TEI/text[1]/body[1]/head[1]/date[1]/@when"
    #   # a non normalized date taken directly from the source material ("Dec 9", "Winter 1889")
    # xpaths["date_display"] = "/TEI/text[1]/body[1]/head[1]/date"
    # xpaths["image_id"] = "/TEI/text/body/pb/@n"
    # xpaths["person"] = "//q/@who"
    # xpaths["source"] = "/TEI/teiHeader/fileDesc/sourceDesc//bibl[1]"
    xpaths["creators"] = {
        "header" => "/TEI/teiHeader/fileDesc/titleStmt/author",
        "bibl" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author",
        "in_text" => "//persName[@type = 'author']"
    }
    xpaths["date"] = {
      "notBefore" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/@notBefore",
      "when" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/@when"
    }
    xpaths["date_display"] = {
      "imprint" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date",
      "default" => "TEI/teiHeader/fileDesc/sourceDesc/bibl/date"
    }
    xpaths["source"] = [
      "/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/title[@level = 'j']",
      "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct[1]/monogr/title[@level = 'j']",
      "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct[1]/monogr/title[@level = 'm']"
    ]
    return xpaths
  end

  #################
  #    GENERAL    #
  #################

  # Add more fields
  #  make sure they follow the custom field naming conventions
  #  *_d, *_i, *_k, *_t
  def assemble_collection_specific
    # @json["field"] = field
    # TODO additional fields for reviews
    # TODO source_sort_k
    # TODO whitman_tei-corresp_data_k
    # TODO whitman_citation_k
  end

  ################
  #    FIELDS    #
  ################

  # Overrides of default behavior
  # Please see docs/tei_to_es.rb for complete instructions and examples

  def category
    "Commentary"
  end

  # note this does not sort the creators
  def creator
    people = []

    header = @xml.xpath(@xpaths["creators"]["header"])
    # TODO check all the code when author is in the header because it is fairly involved XSLT
    if header && header.length > 0
      bibl_auth = @xml.xpath(@xpaths["creators"]["bibl"])
      header.each do |title_auth|
        if (title_auth.xpath("choice/reg").text == "unknown") && (title_auth.xpath("choice/orig").text == "unsigned")
          people << { "name" => "Anonymous", "id" => "" }
        elsif bibl_auth && bibl_auth.first.xpath("choice/reg").text == "unknown" && bibl_auth.first.xpath("choice/orig") != "unsigned"
          people << { "name" => bibl_auth.first.xpath("choice/orig").text }
        # TODO I have not tested this bibl_auth elsif with any TEI examples!!!
        elsif bibl_auth && bibl_auth.xpath("@key")
          bibl_auth.xpath("@key").each do |bibl|
            people << { "name" => bibl.value.gsub(/[\[\]]/, ""), "id" => "" }
          end
        else
          people << { "name" => Datura::Helpers.normalize_space(title_auth.text), "id" => "" }
        end
      end
    # if creator is not in the header, then attempt to grab out of the body instead
    else
      persNames = @xml.xpath(@xpaths["creators"]["in_text"])
      persNames.each do |pers|
        people << { "name" => Datura::Helpers.normalize_space(pers["key"]), id => "" }
      end
    end
    people.uniq
  end

  def date(before=true)
    date = get_text(@xpaths["date"]["notBefore"])
    if !date || date.empty?
      date = get_text(@xpaths["date"]["when"])
    end
    Datura::Helpers.date_standardize(date, before)
  end

  def date_display
    date = get_text(@xpaths["date_display"]["imprint"])
    if date.empty?
      date = get_text(@xpaths["date_display"]["default"])
    end
    date
  end

  # TODO in production solr index this is always blank string, I am assuming it's a periodical
  # for the purposes of this first quick pass
  def format
    "periodical"
  end

  def language
    # TODO verify that none of these are primarily english
    "en"
  end

  # def languages
  #   # TODO verify that none of these are multiple languages
  #   [ "en" ]
  # end

  # TODO medium, person, rights, rights_uri, rights_holder

  # TODO can change this behavior once datura is updated to
  # return nil instead of empty strings
  # TODO reusing source but look into whether this is actually the publisher
  def citation
    pub = get_text(@xpaths["source"])
    pub.empty? ? nil : { "publisher" => pub }
  end

  # TODO source_sort not added
  def source
    source = ""
    @xpaths["source"].each do |xpath|
      source = get_text(xpath)
      break if source && source.length > 0
    end
    source
  end

  def category2
    "reviews"
  end

  # TODO text field requires an override for source

  def title
    title = get_text(@xpaths["title"])
    title.gsub(/[\[\]]/, "")
  end

  def uri
    "#{@options["site_url"]}/criticism/reviews/tei/#{@filename}.html"
  end

  # TODO works....seems like the reviews are likely reviewing a specific work so this shouldn't be hard to grab
  # if I know what field to look for

end
