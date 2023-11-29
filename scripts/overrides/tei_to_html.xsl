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



</xsl:stylesheet>
