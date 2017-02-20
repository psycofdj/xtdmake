<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
    <html>
      <head>
        <title>Jmeter report</title>
        <link href="/data/gitlab-cache/root/valkey/feature/ci_runner/precise/reports/contribs//bootstrap/css/bootstrap.min.css" rel="stylesheet"/>
        <link href="/data/gitlab-cache/root/valkey/feature/ci_runner/precise/reports/contribs//bootstrap/css/bootstrap-theme.min.css" rel="stylesheet"/>
        <script src="/data/gitlab-cache/root/valkey/feature/ci_runner/precise/reports/contribs//jquery/jquery.min.js"></script>
        <script src="/data/gitlab-cache/root/valkey/feature/ci_runner/precise/reports/contribs//bootstrap/js/bootstrap.min.js"></script>
        <script type="text/javascript">
         <![CDATA[
           $(document).ready(function() {
             $("button.section").click(function() {
               var l_tr        = $(this).parents("tr");
               var l_id        = l_tr.attr("id");
               var l_class     = "details-" + l_id;
               $("." + l_class).toggle();
               $(this).toggleClass("glyphicon-plus");
               $(this).toggleClass("glyphicon-minus");
             });
             $("#btn-all").click(function() {
               if ($(this).hasClass("glyphicon-minus")) {
                 $(".details").hide();
                 $("button.section").addClass("glyphicon-plus");
                 $("button.section").removeClass("glyphicon-minus");
               } else {
                 $(".details").show();
                 $("button.section").removeClass("glyphicon-plus");
                 $("button.section").addClass("glyphicon-minus");
               }
               $(this).toggleClass("glyphicon-plus");
               $(this).toggleClass("glyphicon-minus");
             });
           });
         ]]>
        </script>
        <style>
         tr.details {
           display:none;
         }
         pre {
           padding:1px;
           font-size:10px;
           overflow-x:auto;
           white-space: pre-wrap;       /* css-3 */
           white-space: -moz-pre-wrap;  /* Mozilla, since 1999 */
           white-space: -pre-wrap;      /* Opera 4-6 */
           white-space: -o-pre-wrap;    /* Opera 7 */
           word-wrap: break-word;
         }
        </style>
      </head>
      <body bgcolor="#ffffff" style="padding-top:15px;">
        <div class="container-fluid">

          <div class="row">
            <div class="col-lg-6 col-lg-offset-3">
              <div class="panel panel-default">
                <div class="panel-heading">Summary</div>
                <div class="panel-body">
                  <table class="table table-striped table-bordered table-condensed small">
                    <thead>
                      <tr>
                        <th>Number of tests</th>
                        <th>Number of success</th>
                        <th>Number of failures</th>
                        <th>% Success</th>
                      </tr>
                    </thead>
                    <tbody>
                      <xsl:variable name="total"   select="count(./testResults/httpSample) + count(./testResults/sample)"/>
                      <xsl:variable name="success" select="count(./testResults/httpSample[@s='true']) + count(./testResults/sample[@s='true'])"/>
                      <xsl:variable name="failure" select="count(./testResults/httpSample[@s='false']) + count(./testResults/sample[@s='false'])"/>
                      <td><xsl:value-of select="$total" /></td>
                      <td><xsl:value-of select="$success" /></td>
                      <td><xsl:value-of select="$failure" /></td>
                      <td><xsl:value-of select="format-number(($success * 100) div $total, '##.##')" /></td>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>


          <div class="row">
            <div class="col-lg-10 col-lg-offset-1">
              <div class="panel panel-default">
                <div class="panel-heading">Details</div>
                <div class="panel-body">
                  <table class="table table-striped table-bordered table-condensed small">
                    <thead>
                      <tr>
                        <th style="width:120px;" class="text-left">
                          <div class="btn-group">
                            <button id="btn-all" class="btn btn-xs btn-success glyphicon glyphicon-plus"/>
                          </div>
                        </th>
                        <th>Test Name</th>
                      </tr>
                    </thead>
                    <tbody>
                      <xsl:apply-templates select="./testResults/*"/>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="sample">
    <xsl:variable name="id" select="generate-id(.)"/>
    <xsl:element name="tr">
      <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
      <xsl:attribute name="style">margin-top:10px;</xsl:attribute>
      <xsl:choose>
        <xsl:when test="@s = 'true'">
          <xsl:attribute name="class">success</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">danger</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <td class="center">
        <button class="btn btn-xs btn-primary glyphicon glyphicon-plus section"/>
      </td>
      <td><xsl:value-of select="./@lb"/></td>
    </xsl:element>
    <xsl:if test="./requestHeader != ''">
      <tr class="details details-{$id}">
        <td>Request Header</td>
        <td><pre><xsl:value-of select="./requestHeader"/></pre></td>
      </tr>
    </xsl:if>
    <xsl:if test="./responseHeader != ''">
    <tr class="details details-{$id}">
      <td>Response Header</td>
      <td><pre><xsl:value-of select="./responseHeader"/></pre></td>
    </tr>
    </xsl:if>
    <xsl:if test="./responseData != ''">
    <tr class="details details-{$id}">
      <td>Response Data</td>
      <td><pre><xsl:value-of select="./responseData"/></pre></td>
    </tr>
    </xsl:if>
    <xsl:if test="./samplerData != ''">
    <tr class="details details-{$id}">
      <td>Sampler Data</td>
      <td><pre><xsl:value-of select="./samplerData"/></pre></td>
    </tr>
    </xsl:if>
  </xsl:template>

  <xsl:template match="httpSample">
    <xsl:variable name="id" select="generate-id(.)"/>
    <xsl:element name="tr">
      <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
      <xsl:attribute name="style">margin-top:10px;</xsl:attribute>
      <xsl:choose>
        <xsl:when test="@s = 'true'">
          <xsl:attribute name="class">success</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">danger</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <td>
        <button class="btn btn-xs btn-primary glyphicon glyphicon-plus section"/>
      </td>
      <td><xsl:value-of select="./@lb"/></td>
    </xsl:element>
    <xsl:if test="./method != ''">
    <tr class="details details-{$id}">
      <td>Method</td>
      <td><pre><xsl:value-of select="./method"/></pre></td>
    </tr>
    </xsl:if>
    <xsl:if test="./java.net.URL != ''">
      <tr class="details details-{$id}">
        <td>Url</td>
        <td><pre><xsl:value-of select="./java.net.URL"/></pre></td>
      </tr>
    </xsl:if>
    <xsl:if test="./queryString != ''">
    <tr class="details details-{$id}">
      <td>Query</td>
      <td><pre><xsl:value-of select="./queryString"/></pre></td>
    </tr>
    </xsl:if>
    <xsl:if test="./requestHeader != ''">
    <tr class="details details-{$id}">
      <td>Request Header</td>
      <td><pre><xsl:value-of select="./requestHeader"/></pre></td>
    </tr>
    </xsl:if>
    <xsl:if test="./responseHeader != ''">
    <tr class="details details-{$id}">
      <td>Response Header</td>
      <td><pre><xsl:value-of select="./responseHeader"/></pre></td>
    </tr>
    </xsl:if>
    <xsl:if test="./responseData != ''">
    <tr class="details details-{$id}">
      <td>Response Data</td>
      <td><pre><xsl:value-of select="./responseData"/></pre></td>
    </tr>
    </xsl:if>
    <xsl:if test="./samplerData != ''">
    <tr class="details details-{$id}">
      <td>Sampler Data</td>
      <td><pre><xsl:value-of select="./samplerData"/></pre></td>
    </tr>
    </xsl:if>
    <xsl:for-each select="./assertionResult">
      <xsl:element name="tr">
        <xsl:attribute name="class">details details-<xsl:value-of select="$id"/></xsl:attribute>
        <td>assert</td>
        <xsl:element name="td">
          <xsl:choose>
            <xsl:when test="./failure = 'false'">
              <xsl:attribute name="class"></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="class">danger</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:value-of select="./name"/>
          <xsl:if test="./failureMessage != ''">
            <pre><xsl:value-of select="./failureMessage"/></pre>
          </xsl:if>
        </xsl:element>
      </xsl:element>
    </xsl:for-each>

  </xsl:template>



</xsl:stylesheet>
