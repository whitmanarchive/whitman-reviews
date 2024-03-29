require_relative "../../../whitman-scripts/scripts/ruby/get_works_info.rb"
require_relative "../../../whitman-scripts/scripts/archive-wide/overrides.rb"

class TeiToEs

  ################
  #    XPATHS    #
  ################

  # in the below example, the xpath for "person" is altered
  def override_xpaths
    xpaths = {}
    # xpaths["image_id"] = "/TEI/text/body/pb/@n"
    # xpaths["person"] = "//q/@who"
    # xpaths["source"] = "/TEI/teiHeader/fileDesc/sourceDesc//bibl[1]"
    xpaths["contributors"] =
      ["/TEI/teiHeader/fileDesc/titleStmt/respStmt/persName"]
    xpaths["creators"] = {
        "header" => "/TEI/teiHeader/fileDesc/titleStmt/author",
        "bibl" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author",
        "in_text" => "//persName[@type = 'author']"
    }
    xpaths["date"] = {
      "when" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/@when"
    }
    xpaths["date_display"] =
      "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date"
    xpaths["format"] = "/TEI/text/@type"
    xpaths["rights"] = "/TEI/teiHeader/fileDesc/publicationStmt/availability"
    xpaths["rights_holder"] =
      "/TEI/teiHeader/fileDesc/publicationStmt/distributor"
    xpaths["rights_uri"] =
      "/TEI/teiHeader/fileDesc/publicationStmt/availability//ref/@target"
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

  def category2
    "Commentary / Reviews"
  end

  def citation
    # WorksInfo is get_works_info.rb in whitman-scripts repo
    @works_info = WorksInfo.new(xml, @id, @options["threads"], work_xpath = ".//relations/work/@ref")
    ids, names = @works_info.get_works_info
    citations = []
    if ids && ids.length > 0
      ids.each_with_index do |id, idx|
        name = names[idx]
        citations << {
          "id" => id,
          "title" => name,
          "role" => "whitman_id"
        }
      end
    end
    pub = get_text(@xpaths["source"])
    if !pub.empty? 
      citations << { "publisher" => pub }
    end
    citations
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
    get_text(@xpaths["date_display"])
  end

  # TODO in production solr index this is always blank string, I am assuming it's a periodical
  # for the purposes of this first quick pass
  def format
    get_text(@xpaths["format"])
  end

  def language
    # TODO verify that none of these are primarily english
    "en"
  end

  # def languages
  #   # TODO verify that none of these are multiple languages
  #   [ "en" ]
  # end

  # TODO medium, person
  def rights
    get_text(@xpaths["rights"])
  end

  def rights_uri
    get_text(@xpaths["rights_uri"])
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
