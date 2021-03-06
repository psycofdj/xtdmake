<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
    <html>
      <head>
        <title>Unittest report</title>
        <link href="../../contribs/bootstrap/css/bootstrap.min.css" rel="stylesheet"/>
        <link href="../../contribs/bootstrap/css/bootstrap-theme.min.css" rel="stylesheet"/>
        <script src="../../contribs/jquery/jquery.min.js"></script>
        <script src="../../contribs/bootstrap/js/bootstrap.min.js"></script>
        <script type="text/javascript">
         <![CDATA[
           $(document).ready(function() {
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

                  <xsl:variable name="tests_total">
                    <xsl:value-of select="count(./Site/Testing/Test)"/>
                  </xsl:variable>
                  <xsl:variable name="tests_failed">
                    <xsl:value-of select="count(./Site/Testing/Test[@Status!='passed'])"/>
                  </xsl:variable>
                  <xsl:variable name="tests_passed">
                    <xsl:value-of select="count(./Site/Testing/Test[@Status='passed'])"/>
                  </xsl:variable>

                  <table class="table table-striped table-bordered table-condensed small">
                    <tbody>
                      <tr>
                        <th>Total tests</th>
                        <td><xsl:value-of select="$tests_total"/></td>
                      </tr>
                      <tr>
                        <th>Test passed</th>
                        <td><xsl:value-of select="$tests_passed"/> (<xsl:value-of select="format-number($tests_passed div $tests_total * 100, '###.##')"/>%) </td>
                      </tr>
                      <tr>
                        <th>Test failed</th>
                        <td><xsl:value-of select="$tests_failed"/> (<xsl:value-of select="format-number($tests_failed div $tests_total * 100, '###.##')"/>%) </td>
                      </tr>
                      <tr>
                        <th>Duration</th>
                        <td><xsl:value-of select="./Site/Testing/EndTestTime - ./Site/Testing/StartTestTime"/> sec(s)</td>
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
                        <th>Test Name</th>
                        <th>Status</th>
                        <th>Exit code</th>
                        <th>Exit value</th>
                        <th>Executime Time (sec)</th>
                      </tr>
                    </thead>
                    <tbody>
                      <xsl:apply-templates select="./Site/Testing/Test"/>
                    </tbody>
                    <xsl:if test="count(./Site/Testing/Test) = 0">
                      <tfoot>
                        <tr><td class="text-center" colspan="6">No test found</td></tr>
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
    <xsl:variable name="myclass">
      <xsl:choose>
        <xsl:when test="./@Status='passed'">success</xsl:when>
        <xsl:when test="./@Status='failed'">danger</xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="exit_code">
      <xsl:choose>
        <xsl:when test="./@Status='passed'">0</xsl:when>
        <xsl:when test="./@Status='failed'">
          <xsl:value-of select="./Results/NamedMeasurement[@name='Exit Code']/Value"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="exit_value">
      <xsl:choose>
        <xsl:when test="./@Status='passed'">OK</xsl:when>
        <xsl:when test="./@Status='failed'">
          <xsl:value-of select="./Results/NamedMeasurement[@name='Exit Value']/Value"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <tr id="{generate-id(Name)}">
      <xsl:attribute name="class"><xsl:value-of select="$myclass"/></xsl:attribute>
      <td class="text-center">
        <button class="btn btn-xs btn-primary glyphicon glyphicon-plus"/>
      </td>
      <td> <xsl:value-of select="./Name"/> </td>
      <td> <xsl:value-of select="./@Status"/> </td>
      <td> <xsl:value-of select="$exit_code"/> </td>
      <td> <xsl:value-of select="$exit_value"/> </td>
      <td> <xsl:value-of select="format-number(./Results/NamedMeasurement[@name='Execution Time']/Value, '#.##')"/> </td>
    </tr>
    <tr id="{generate-id(Name)}-details" style="display: none;">
      <td colspan="6">
        <div>
          <table class="table table-striped table-bordered table-condensed small">
            <tbody>
              <tr>
                <td>Command line</td>
                <td> <xsl:value-of select="./FullCommandLine"/> </td>
              </tr>
              <tr>
                <td>Logs</td>
                <td>
                  <pre style="max-height:300px; overflow:scroll;" class="small">
                    <xsl:choose>
                      <xsl:when test="./Results/Measurement/Value = ''">[ no output from test ]</xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="./Results/Measurement/Value"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </pre>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>
