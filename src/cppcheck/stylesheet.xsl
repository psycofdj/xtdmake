<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
    <html>
      <head>
        <title>Cppcheck report</title>
        <link href="../../contribs/bootstrap/css/bootstrap.min.css" rel="stylesheet"/>
        <link href="../../contribs/bootstrap/css/bootstrap-theme.min.css" rel="stylesheet"/>
        <script src="../../contribs/jquery/jquery.min.js"></script>
        <script src="../../contribs/bootstrap/js/bootstrap.min.js"></script>
      </head>
      <body bgcolor="#ffffff" style="padding-top:50px;">
        <div class="container-fluid">
          <div class="row">
            <div class="col-lg-10 col-lg-offset-1">
              <div class="panel panel-default">
                <div class="panel-heading">Summary</div>
                <div class="panel-body">
                  <table class="table table-striped table-bordered table-hover table-condensed small">
                    <thead>
                      <tr>
                        <th>File</th>
                        <th>Line</th>
                        <th>Identifier</th>
                        <th>Severity</th>
                        <th>Message</th>
                      </tr>
                    </thead>
                    <tbody>
                      <xsl:apply-templates select="./results"/>
                    </tbody>
                    <xsl:if test="count(./results/error) = 0">
                      <tfoot>
                        <tr><td class="text-center" colspan="5">No error found</td></tr>
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

  <xsl:template match="error">
    <xsl:variable name="myclass">
      <xsl:choose>
        <xsl:when test="./@severity='error'">danger</xsl:when>
        <xsl:when test="./@severity='warning'">warning</xsl:when>
        <xsl:when test="./@severity='style'">active</xsl:when>
        <xsl:when test="./@severity='performance'">active</xsl:when>
        <xsl:when test="./@severity='portability'">active</xsl:when>
        <xsl:when test="./@severity='information'">success</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <tr>
      <xsl:attribute name="class"><xsl:value-of select="$myclass"/></xsl:attribute>
      <td> <xsl:value-of select="./@file"/> </td>
      <td> <xsl:value-of select="./@line"/> </td>
      <td> <xsl:value-of select="./@id"/> </td>
      <td> <xsl:value-of select="./@severity"/> </td>
      <td> <xsl:value-of select="./@msg"/> </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>
