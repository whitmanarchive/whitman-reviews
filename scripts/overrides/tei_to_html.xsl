<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" 
  xmlns:whitman="http://www.whitmanarchive.org/namespace"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0"
  exclude-result-prefixes="xsl tei xs whitman">
  
  <!-- ==================================================================== -->
  <!--                             IMPORTS                                  -->
  <!-- ==================================================================== -->
  
  <xsl:import href="../.xslt-datura/tei_to_html/tei_to_html.xsl"/>
  
  <xsl:import href="../../../whitman-scripts/scripts/archive-wide/overrides.xsl"/>

  
  
  <!-- To override, copy this file into your collection's script directory
    and change the above paths to:
    "../../.xslt-datura/tei_to_html/lib/formatting.xsl"
 -->
  
  <!-- For display in TEI framework, have changed all namespace declarations to http://www.tei-c.org/ns/1.0. If different (e.g. Whitman), will need to change -->
  <xsl:output method="xml" indent="no" encoding="UTF-8" omit-xml-declaration="no"/>
  
  <!-- consider moving to overrides.xsl -->
  <xsl:template match="hi[@rend='superscript']">
    <sup>
      <xsl:attribute name="class">
        <xsl:value-of select="@rend"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="add_attributes"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </sup>
  </xsl:template>
  
  <!-- add overrides for this section here -->
  
  <xsl:variable name="top_metadata">
    <ul>
        <!-- source field -->
        <li>
            <strong>Source: </strong>
            <xsl:choose>
                <xsl:when test="//sourceDesc//monogr/title">
                    <em>
                        <xsl:value-of
                            select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct[1]/monogr/title"/>
                    </em>
                    <xsl:text> </xsl:text>
                    <xsl:if test="//sourceDesc//monogr//pubPlace">[<xsl:value-of select="//sourceDesc//monogr//pubPlace"/>]</xsl:if>
                    <xsl:text> </xsl:text>
                    
                    <xsl:if test="//sourceDesc//biblScope[@type='volume']">
                        <xsl:value-of select="//sourceDesc//biblScope[@type='volume']"/> <xsl:text> (</xsl:text> 
                    </xsl:if>
                    <xsl:if test="//sourceDesc//date[@type='circa']"><xsl:text> c. </xsl:text></xsl:if>
                    <xsl:value-of
                        select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct[1]/monogr/imprint/date/."/>
                    <xsl:if test="//sourceDesc//biblScope[@type='volume']">
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                    <xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/biblScope[@type='pages']"><xsl:text>: </xsl:text>
                        
                        <xsl:choose>
                            <xsl:when test="//sourceDesc/biblStruct[@type='transcription']">
                                <xsl:value-of
                                    select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct[@type='original']/monogr/imprint/biblScope[@type='pages']"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/biblScope[@type='pages']"
                                />
                            </xsl:otherwise>
                        </xsl:choose></xsl:if>
                    <xsl:text>.</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates
                        select="TEI/teiHeader/fileDesc/sourceDesc/bibl/note[@type='project']"
                    />
                </xsl:otherwise>
            </xsl:choose>
            
        
        <xsl:choose>
            <xsl:when test="//sourceDesc/bibl/note[@type='project']"/>
            <xsl:otherwise>
                <xsl:text> </xsl:text><span class="tei_encodingDesc"><xsl:apply-templates select="//encodingDesc"/></span>
            </xsl:otherwise>
        </xsl:choose>
            <xsl:text> </xsl:text>For a description of the editorial rationale behind our treatment of the reviews, see our <a href="../about/editorial-policies#reviews">statement of editorial policy</a>.

        </li>
    </ul>
  </xsl:variable>

  <!-- <ref>s footnotes -->  
    <xsl:template match="text//ref[@target]">
      <xsl:choose>
        <xsl:when test="@n">
          <a>
            <xsl:attribute name="href">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="@target"/>
            </xsl:attribute>
            <sup class="footnote_sup_link">
                <xsl:attribute name="id">
                    <xsl:text>ref_</xsl:text>
                    <xsl:value-of select="@xml:id"/>
                </xsl:attribute>
                <xsl:value-of select="@n"/>
            </sup>
        </a>
        </xsl:when>
      <!-- make sure non-linked, non-footnote <ref>s like * and † in anc.00065 are still displayed -->
        <xsl:otherwise>
          <xsl:apply-templates />
        </xsl:otherwise>
      </xsl:choose>
        
    </xsl:template>

    <!-- / <ref>s footnotes -->

    <!-- don't display duplicated <div1 type="notes"> -->
      <xsl:template match="//div1[@type='notes']">
      </xsl:template>
    <!-- / don't display -->

  <!-- note -->
  <xsl:template match="note">
    <xsl:choose>
      <xsl:when test="@place='foot'">
        <span>
          <xsl:attribute name="class">
            <xsl:call-template name="add_attributes"/>
            <xsl:text>foot </xsl:text>
          </xsl:attribute>
          <xsl:if test="@xml:id">
            <xsl:attribute name="id" select="@xml:id"/>
          </xsl:if>
          <a>
            <xsl:attribute name="href">
              <xsl:text>#</xsl:text>
              <xsl:text>foot</xsl:text>
              <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
            <xsl:attribute name="id">
              <xsl:text>body</xsl:text>
              <xsl:value-of select="@xml:id"/>
            </xsl:attribute>

            <xsl:text>(</xsl:text>
            <xsl:value-of select="substring(@xml:id, 2)"/>
            <xsl:text>)</xsl:text>
          </a>
        </span>
      </xsl:when>

      <!-- resp wwa from legacy_xslt -->
      <xsl:when test="@resp='wwa'">
        <span>
          <sup xmlns="http://www.w3.org/1999/xhtml">
            <a>
              <xsl:attribute name="href">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
            <xsl:attribute name="id">
              <xsl:text>r</xsl:text>
              <xsl:number count="note[@resp='wwa']" level="any"/></xsl:attribute>
              <xsl:number count="note[@resp='wwa']" level="any"/>
            </a>
          </sup>
        </span>
      </xsl:when>
      <!-- /resp wwa -->

      <!-- rep unk from legacy_xslt -->
      <xsl:when test="@resp='unk'">
        <p>
        <xsl:apply-templates/></p>
      </xsl:when>
      <!-- / resp unk -->

      <xsl:otherwise>
        <span>
          <xsl:attribute name="class">
            <xsl:call-template name="add_attributes"/><xsl:text> </xsl:text>
            <xsl:value-of select="name()"/>
          </xsl:attribute>
          <xsl:if test="@xml:id">
            <xsl:attribute name="id" select="@xml:id"/>
          </xsl:if>
          <span>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
          </span>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


   <!-- move notes to end of doc -->
    <xsl:template match="text">
      <xsl:apply-templates/>
      <xsl:if test="//note[@type='editorial'] or //note[@type='authorial']">
        <hr />
        <div class="notes">
          <h3 span="notes_title">Notes</h3>
          <xsl:for-each select="//text//note">
            <p>
              <xsl:attribute name="id">
                  <xsl:value-of select="@xml:id"/>
              </xsl:attribute>
              <xsl:value-of select="count(preceding::note[ancestor::text]) +1"/>
              <xsl:text>. </xsl:text>
              <xsl:apply-templates/>
              <xsl:text> [</xsl:text>
              <a>
                <xsl:attribute name="href">
                    <xsl:text>#ref_</xsl:text>
                    <xsl:value-of select="@target"/>
                </xsl:attribute>
                <xsl:text>back</xsl:text>
              </a>
              <xsl:text>]</xsl:text>
            </p>
                <xsl:text>
          
        </xsl:text>
          </xsl:for-each>
        </div>
      </xsl:if>
    </xsl:template>
  <!-- / move notes -->


  <!-- sic and corr -->
  <!-- overriding because (in anc.00062 at least) sic is shown and corr is hidden -->
  <xsl:template match="choice[child::sic]">
    <span class="tei_choice">
      <span class="tei_sic tei_sic_no_strikethrough">
        <xsl:value-of select="sic"/>&#8203;
      </span>
    </span>
  </xsl:template>
<!-- / sic and corr -->



</xsl:stylesheet>
