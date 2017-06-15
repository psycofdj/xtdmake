<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="/">
    <html>
      <head>
        <title>Code Duplication report</title>
        <link href="../../contribs/bootstrap/css/bootstrap.min.css" rel="stylesheet"/>
        <link href="../../contribs/bootstrap/css/bootstrap-theme.min.css" rel="stylesheet"/>
        <link href="../../contribs/highlightjs/styles/default.css" rel="stylesheet"/>
        <script src="../../contribs/jquery/jquery.min.js"></script>
        <script src="../../contribs/bootstrap/js/bootstrap.min.js"></script>
        <script src="../../contribs/highlightjs/highlight.pack.js"></script>
        <script type="text/javascript">
         <![CDATA[
           $(document).ready(function() {
             $('pre code').each(function(i, block) {
               hljs.highlightBlock(block);
             });
             
             $("button").click(function() {
               var l_tr        = $(this).parents("tr");
               var l_id        = l_tr.attr("id");
               var l_detailsID = l_id + "-details";
               $("#" + l_detailsID).toggle();
             });
           });
         ]]>
        </script>
        <style>
          <![CDATA[
            pre {
              white-space: pre-wrap;
              white-space: -moz-pre-wrap;
              white-space: -pre-wrap;
              white-space: -o-pre-wrap;
              word-wrap: break-word;
            }
          ]]>
        </style>
      </head>
      <body bgcolor="#ffffff" style="padding-top:50px;">
        <div class="container-fluid">
          <div class="row">
            <div class="col-lg-4 col-lg-offset-4">
              <div class="panel panel-default">
                <div class="panel-heading">Summary report</div>
                <div class="panel-body">

                  <xsl:variable name="duplicated_blocks">
                    <xsl:value-of select="count(./pmd-cpd/duplication)"/>
                  </xsl:variable>
                  <xsl:variable name="duplicated_lines">
                    <xsl:value-of select="sum(./pmd-cpd/duplication/@lines)"/>
                  </xsl:variable>


                  <table class="table table-striped table-bordered table-condensed small">
                    <tbody>
                      <tr>
                        <th>Detected blocks</th>
                        <td><xsl:value-of select="$duplicated_blocks"/></td>
                      </tr>
                      <tr>
                        <th>Duplicated lines</th>
                        <td><xsl:value-of select="$duplicated_lines"/></td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>

          <div class="row">
            <div class="col-lg-10 col-lg-offset-1">
              <div class="panel panel-default">
                <div class="panel-heading">Full report</div>
                <div class="panel-body">
                  <table class="table table-striped table-bordered table-condensed small">
                    <thead>
                      <tr>
                        <th style="width:50px;"></th>
                        <th>Block ID</th>
                        <th>Number of lines</th>
                        <th>Number of tokens</th>
                        <th>Associated files</th>
                      </tr>
                    </thead>
                    <tbody>
                      <xsl:apply-templates select="./pmd-cpd/duplication"/>
                    </tbody>
                    <xsl:if test="count(./pmd-cpd/duplication) = 0">
                      <tfoot>
                        <tr><td class="text-center" colspan="6">No duplication found</td></tr>
                      </tfoot>
                    </xsl:if>
                  </table>
                </div>
              </div>
            </div>
          </div>
        </div>
      </body>
    </html>
  </xsl:template>



  <xsl:template match="*">
    <xsl:variable name="c_id">
      <xsl:value-of select="generate-id(./codefragment)"/>
    </xsl:variable>

    <tr>
      <xsl:attribute name="id"><xsl:value-of select="$c_id"/></xsl:attribute>
      <td class="text-center">
        <button class="btn btn-xs btn-primary glyphicon glyphicon-plus"/>
      </td>
      <td> ID </td>
      <td> <xsl:value-of select="./@lines"/> </td>
      <td> <xsl:value-of select="./@tokens"/> </td>
      <td> <xsl:value-of select="count(./file)"/> </td>
    </tr>

    <tr style="display: none;">
      <xsl:attribute name="id"><xsl:value-of select="$c_id"/>-details</xsl:attribute>
      <td colspan="5">
        <div>
          <table class="table table-striped table-bordered table-condensed small">
            <thead>
              <tr>
                <th>File</th>
                <th>Line</th>
              </tr>
            </thead>
            <tbody>
              <xsl:for-each select="./file">
                <tr>
                  <td> <xsl:value-of select="@path"/> </td>
                  <td> <xsl:value-of select="@line"/> </td>
                </tr>
              </xsl:for-each>
            </tbody>
            <tfoot>
              <tr>
                <td colspan="5">
                  <div>
                    <pre><code class="cpp"><xsl:value-of select="./codefragment"/></code></pre>
                  </div>
                </td>
              </tr>
            </tfoot>
          </table>
        </div>
      </td>
    </tr>

  </xsl:template>
</xsl:stylesheet>
