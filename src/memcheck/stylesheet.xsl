<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
    <html>
      <head>
        <title>Memcheck report</title>
        <link href="../../_static/bootstrap/css/bootstrap.min.css" rel="stylesheet"/>
        <link href="../../_static/bootstrap/css/bootstrap-theme.min.css" rel="stylesheet"/>
        <script src="../../_static/jquery/jquery.min.js"></script>
        <script src="../../_static/bootstrap/js/bootstrap.min.js"></script>
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
      </head>
      <body bgcolor="#ffffff" style="padding-top:50px;">
        <div class="container-fluid">

          <div class="row">
            <div class="col-lg-4 col-lg-offset-4">
              <div class="panel panel-default">
                <div class="panel-heading">Error summary</div>
                <div class="panel-body">
                  <table class="table table-striped table-bordered table-condensed small">
                    <tbody>
                      <xsl:apply-templates select="./memcheck/stats"/>
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
                        <th style="width:50px;" class="text-center">
                          <button class="btn btn-xs btn-success glyphicon glyphicon-minus"/>
                          <button class="btn btn-xs btn-danger  glyphicon glyphicon-plus"/>
                        </th>
                        <th>Test Name</th>
                        <th>Errors</th>
                      </tr>
                    </thead>
                    <tbody>
                      <xsl:apply-templates select="./memcheck/tests/test"/>
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

  <xsl:template match="test">
    <tr id="{generate-id(Name)}" style="margin-top:10px;">
      <td>
        <button class="btn btn-xs btn-primary glyphicon glyphicon-plus"/>
      </td>
      <td><xsl:value-of select="./@name"/></td>
      <td><xsl:value-of select="count(./errors/error)"/></td>
    </tr>

    <tr id="{generate-id(Name)}-cmd">
      <td>
        Command
      </td>
      <td colspan="2">
        <xsl:value-of select="./cmd"/>
      </td>
    </tr>

    <tr id="{generate-id(Name)}-errors">
      <td>
        <button class="btn btn-xs btn-primary glyphicon glyphicon-plus"/>
      </td>
      <td>
        <xsl:value-of select="./errors/error/@kind"/>
      </td>
      <td>
        <xsl:value-of select="./errors/error/@descr"/>
      </td>
    </tr>

  </xsl:template>

  <xsl:template match="stats">
    <xsl:for-each select="./*">
      <tr>
        <th><xsl:value-of select ="name(.)"/></th>
        <td><xsl:value-of select="./@count"/></td>
      </tr>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
