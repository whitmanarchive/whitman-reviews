<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xpath-default-namespace="http://www.whitmanarchive.org/namespace"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  exclude-result-prefixes="#all">

  <!-- ==================================================================== -->
  <!--                               IMPORTS                                -->
  <!-- ==================================================================== -->

  <xsl:import href="../../whitman-scripts/solr/whitman_to_solr.xsl"/>

  <xsl:output indent="yes" omit-xml-declaration="yes"/>

  <!-- ==================================================================== -->
  <!--                           PARAMETERS                                 -->
  <!-- ==================================================================== -->

  <!-- Defined in project config files -->
  <xsl:param name="fig_location"/>  <!-- url for figures -->
  <xsl:param name="file_location"/> <!-- url for tei files -->
  <xsl:param name="figures"/>       <!-- boolean for if figs should be displayed (not for this script, for html script) -->
  <xsl:param name="fw"/>            <!-- boolean for html not for this script -->
  <xsl:param name="pb"/>            <!-- boolean for page breaks in html, not this script -->
  <xsl:param name="project"/>       <!-- longer name of project -->
  <xsl:param name="slug"/>          <!-- slug of project -->
  <xsl:param name="site_url"/>
  <xsl:param name="site_location"/> <!-- being used by something -->


  <!-- ==================================================================== -->
  <!--                            OVERRIDES                                 -->
  <!-- ==================================================================== -->

  <!-- Individual projects can override matched templates from the
       imported stylesheets above by including new templates here -->
  <!-- Named templates can be overridden if included in matched templates
       here.  You cannot call a named template from directly within the stylesheet tag
       but you can redefine one here to be called by an imported template -->

      <!-- The below will override the entire text matching template -->
      <!-- <xsl:template match="text">
        <xsl:call-template name="fake_template"/>
      </xsl:template> -->

      <!-- The below will override templates with the same name -->
      <!-- <xsl:template name="fake_template">
        This fake template would override fake_template if it was defined
        in one of the imported files
      </xsl:template>
  -->

  <!-- ========== category ========== -->

  <xsl:template name="category">
    <field name="category">
      <xsl:text>criticism</xsl:text>
    </field>
  </xsl:template>

  <!-- ========== subCategory ========== -->

  <xsl:template name="subCategory">
    <field name="subCategory">
      <xsl:text>reviews</xsl:text>
    </field>
  </xsl:template>

  <!-- ========== creators ========== -->
  <!-- TODO look into refactoring -->

  <xsl:template name="creators">
    <xsl:choose>
      <!-- When handled in header -->
      <xsl:when test="/TEI/teiHeader/fileDesc/titleStmt/author != ''">
        <!-- All in one field -->
        <field name="creator">
          <xsl:choose>
            <!-- for reviews -->
            <xsl:when
              test="/TEI/teiHeader/fileDesc/titleStmt/author/choice/orig = 'unsigned' and /TEI/teiHeader/fileDesc/titleStmt/author/choice/reg = 'unknown'">
              <xsl:text>Anonymous</xsl:text>
            </xsl:when>
            <xsl:when
              test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author/choice/reg = 'unknown' and /TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author/choice/orig != 'unsigned'">
              <xsl:value-of
                select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author/choice/orig"
              />
            </xsl:when>
            <!-- for reviews -->
            <xsl:when
              test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author/@key">
              <xsl:value-of
                select="translate(/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author/@key, '[]', '')"
              />
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/author">
                <xsl:value-of select="normalize-space(.)"/>
                <xsl:if test="position() != last()">
                  <xsl:text>; </xsl:text>
                </xsl:if>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </field>
        <!-- Individual fields -->
        <xsl:for-each select="/TEI/teiHeader/fileDesc/titleStmt/author">
          <field name="creators">
            <xsl:value-of select="."/>
          </field>
        </xsl:for-each>
      </xsl:when>
      <!-- When handled in document -->
      <xsl:when test="//persName[@type = 'author']">
        <!-- All in one field -->
        <field name="creator">
          <xsl:for-each-group select="//persName[@type = 'author']"
            group-by="substring-after(@key, '#')">
            <xsl:sort select="substring-after(@key, '#')"/>
            <xsl:value-of select="current-grouping-key()"/>
            <xsl:if test="position() != last()">
              <xsl:text>; </xsl:text>
            </xsl:if>
          </xsl:for-each-group>
        </field>
        <!-- Individual fields -->
        <xsl:for-each-group select="//persName[@type = 'author']"
          group-by="substring-after(@key, '#')">
          <field name="creators">
            <xsl:value-of select="current-grouping-key()"/>
          </field>
        </xsl:for-each-group>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <!-- ========== date and dateDisplay ========== -->

  <xsl:template name="date">
    <!-- Eighth field is the item date in human-readable format, pulled from the date in source description. -->
    <field name="dateDisplay">
      <xsl:choose>
        <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date">
          <xsl:value-of
            select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="//sourceDesc/bibl/date"/>
        </xsl:otherwise>
      </xsl:choose>
    </field>

    <!-- Ninth field is a sortable version of the date in the format yyyy-mm-dd pulled from @when or @notBefore on date element in the source description. -->
    <field name="date">
      <xsl:choose>
        <xsl:when
          test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/attribute::notBefore">
          <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/attribute::notBefore"/>
        </xsl:when>
        <xsl:when
          test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/@when">
          <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/@when"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/attribute::when"/>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>

  <xsl:template name="source">
    <!-- whitman_source_sort_s so we can sort by periodical without the a an-->
    <!-- I am assuming that only one of these will hit. If multiples hit, we'll need to do a choose. -->
    <xsl:variable name="tei_source">
      <xsl:for-each select="normalize-space(/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/title[@level = 'j'])">
        <xsl:value-of select="."/>
      </xsl:for-each>
      <xsl:for-each select="normalize-space(/TEI/teiHeader/fileDesc/sourceDesc/biblStruct[1]/monogr/title[@level = 'j'])">
        <xsl:value-of select="."/>
      </xsl:for-each>
      <xsl:for-each select="normalize-space(/TEI/teiHeader/fileDesc/sourceDesc/biblStruct[1]/monogr/title[@level = 'm'])">
        <xsl:value-of select="."/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:if test="not($tei_source = '')">
      <field name="source">
        <xsl:value-of select="$tei_source"/>
      </field>
      <field name="whitman_source_sort_s">
        <xsl:call-template name="normalize_name">
          <xsl:with-param name="string">
            <xsl:value-of select="$tei_source"/>
          </xsl:with-param>
        </xsl:call-template>
      </field>
    </xsl:if>
  </xsl:template>

  <!-- TODO compare this against the correspondence and consider refactoring -->
  <xsl:template name="recipients">
    <xsl:if test="/TEI/teiHeader/profileDesc/particDesc/person/@role = 'recipient'">
      <!-- All in one field -->
      <field name="recipient">
        <xsl:if test="count(//person[@role = 'recipient']) = 1">
          <xsl:value-of select="//person[@role = 'recipient']/persName/attribute::key"/>
        </xsl:if>
        <xsl:if test="count(//person[@role = 'recipient']) = 2">
          <xsl:value-of select="//person[@role = 'recipient'][1]/persName/attribute::key"/>
          <xsl:text>; </xsl:text>
          <xsl:value-of select="//person[@role = 'recipient'][2]/persName/attribute::key"
          />
        </xsl:if>
        <xsl:if test="count(//person[@role = 'recipient']) = 3">
          <xsl:value-of select="//person[@role = 'recipient'][1]/persName/attribute::key"/>
          <xsl:text>; </xsl:text>
          <xsl:value-of select="//person[@role = 'recipient'][2]/persName/attribute::key"/>
          <xsl:text>; </xsl:text>
          <xsl:value-of select="//person[@role = 'recipient'][3]/persName/attribute::key"
          />
        </xsl:if>
        <xsl:if test="count(//person[@role = 'recipient']) &gt; 3">
          <xsl:value-of select="//person[@role = 'recipient'][1]/persName/attribute::key"/>
          <xsl:text>; </xsl:text>
          <xsl:value-of select="//person[@role = 'recipient'][2]/persName/attribute::key"/>
          <xsl:text>; </xsl:text>
          <xsl:value-of select="//person[@role = 'recipient'][3]/persName/attribute::key"/>
          <xsl:text> and others</xsl:text>
        </xsl:if>
      </field>
      <!-- Individual fields -->
      <xsl:for-each
        select="/TEI/teiHeader/profileDesc/particDesc/person[@role = 'recipient']/persName/@key">
        <field name="recipients">
          <xsl:value-of select="."/>
        </field>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="text_source">
    <xsl:value-of select="normalize-space(/TEI/teiHeader/fileDesc/sourceDesc/bibl[1]/title[@level = 'j'])"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="normalize-space(/TEI/teiHeader/fileDesc/sourceDesc/biblStruct[1]/monogr/title[@level = 'j'])"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="normalize-space(/TEI/teiHeader/fileDesc/sourceDesc/biblStruct[1]/monogr/title[@level = 'm'])"/>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template name="other_fields">
    <!-- ==============
    Whitman Specific
     ================ -->

    <!--whitman_tei-corresp_id-->
    <!--whitman_tei-corresp_title-->
    <!--whitman_tei-corresp_data-->

    <xsl:for-each select="tokenize(/TEI/teiHeader/fileDesc/titleStmt/title/@corresp, ' ')">
      <xsl:variable name="title_id" select="."/>
      <field name="whitman_tei-corresp_id_ss">
        <xsl:value-of select="$title_id"/>
      </field>
      <field name="whitman_tei-corresp_title_ss">
        <xsl:value-of
          select="document('reviews_name_index.xml')//item[@corresp = $title_id]/title"/>
      </field>
      <field name="whitman_tei-corresp_data_ss">
        <xsl:value-of select="$title_id"/>
        <xsl:text>|</xsl:text>
        <xsl:value-of
          select="document('reviews_name_index.xml')//item[@corresp = $title_id]/title"/>
      </field>
    </xsl:for-each>

    <!--whitman_citation-->
    <!-- TODO consider options to refactor -->
    <field name="whitman_citation_s">
      <xsl:variable name="creator">
        <xsl:choose>
          <xsl:when test="count(/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author) = 2">
            <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[1]/choice/orig">
              <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[1]/choice/reg != 'unknown' or /TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[1]/choice/orig = 'unsigned'">
                <xsl:text>[</xsl:text>
              </xsl:if>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[1]/choice/orig = 'unsigned' and /TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[1]/choice/reg = 'unknown'">
                <xsl:text>Anonymous</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[1]/@key"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[1]/choice/orig">
              <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[1]/choice/reg != 'unknown' or /TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[1]/choice/orig = 'unsigned'">
                <xsl:text>]</xsl:text>
              </xsl:if>
            </xsl:if>
            <xsl:text>; </xsl:text>
            <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[2]/choice/orig">
              <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[2]/choice/reg != 'unknown' or /TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[2]/choice/orig = 'unsigned'">
                <xsl:text>[</xsl:text>
              </xsl:if>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[2]/choice/orig = 'unsigned' and /TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[2]/choice/reg = 'unknown'">
                <xsl:text>Anonymous</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[2]/@key"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[2]/choice/orig">
              <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[1]/choice/reg != 'unknown' or /TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[1]/choice/orig = 'unsigned'">
                <xsl:text>]</xsl:text>
              </xsl:if>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author/choice/orig">
              <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[1]/choice/reg != 'unknown' or /TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[1]/choice/orig = 'unsigned'">
                <xsl:text>[</xsl:text>
              </xsl:if>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author/choice/orig = 'unsigned' and /TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author/choice/reg = 'unknown'">
                <xsl:text>Anonymous</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author/@key"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author/choice/orig">
              <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[1]/choice/reg != 'unknown' or /TEI/teiHeader/fileDesc/sourceDesc/biblStruct/analytic/author[1]/choice/orig = 'unsigned'">
                <xsl:text>]</xsl:text>
              </xsl:if>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="title">
        <xsl:apply-templates
          select="/TEI/teiHeader/fileDesc/titleStmt/title[@type = 'main']/node()"/>
      </xsl:variable>
      <xsl:variable name="periodical">
        <xsl:choose>
          <xsl:when test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/title[@level = 'j']">
            <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/title[@level = 'j']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/title[@level = 'm']"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="volume">
        <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/biblScope[@type = 'volume']"/>
      </xsl:variable>
      <xsl:variable name="date">
        <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/biblScope[@type = 'volume']">
          <xsl:text>(</xsl:text>
        </xsl:if>
        <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date"/>
        <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/biblScope[@type = 'volume']">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:variable>
      <xsl:variable name="pages">
        <xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/biblScope[@type = 'pages']"/>
      </xsl:variable>
      <xsl:value-of select="$creator"/>
      <xsl:text>, "</xsl:text>
      <!-- Add to this a check to see if there is a ", and if so, changing it to a ' todo kmd-->
      <xsl:variable name="quote">&quot;</xsl:variable>
      <xsl:variable name="apos">&apos;</xsl:variable>
      <xsl:copy-of select="translate($title, $quote, $apos)"/>
      <xsl:text>," </xsl:text>
      <xsl:text>{em}</xsl:text>
      <xsl:value-of select="$periodical"/>
      <xsl:text>{/em}</xsl:text>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$volume"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$date"/>
      <xsl:text>: </xsl:text>
      <xsl:value-of select="$pages"/>
    </field>
  </xsl:template>

</xsl:stylesheet>
