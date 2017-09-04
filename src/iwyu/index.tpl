<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Include sanity report</title>
    <link href="../../contribs/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <link href="../../contribs/bootstrap/css/bootstrap-theme.min.css" rel="stylesheet">
    <script src="../../contribs/jquery/jquery.min.js"></script>
    <script src="../../contribs/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript">
     $(document).ready(function() {
       $("button").click(function() {
         var l_tr        = $(this).parents("tr");
         var l_id        = l_tr.attr("id");
         var l_detailsID = l_id + "-details";
         $("#" + l_detailsID).toggle();
       });
     });
    </script>
    <style>
     .header {
max-width:500px;
       min-height:150px;
       max-height:150px;
       overflow: scroll;
     }

     pre {
       /* white-space: pre-wrap;
          white-space: -moz-pre-wrap;
          white-space: -pre-wrap;
          white-space: -o-pre-wrap;
          word-wrap: break-word; */
       overflow: scroll;
     }
    </style>
  </head>
  <body bgcolor="#ffffff" style="padding-top:50px;">
    <div class="container-fluid">
      <div class="row">
        <div class="col-lg-4 col-lg-offset-4"><div class="panel panel-default">
          <div class="panel-heading">Summary report</div>
          <div class="panel-body">
            <table class="table table-striped table-bordered table-condensed small">
              <tbody>
                <tr>
                  <th>Analyzed files</th>
                  <td>${len(items)}</td>
                </tr>
                <tr>
                  <th>Ok files</th>
                  <td>${ len({x:y for x,y in items.items() if y["errors"] == False and y["full"] == [] }) }</td>
                </tr>
                <tr>
                  <th>Error founds</th>
                  <td>${ len({x:y for x,y in items.items() if y["errors"] == False and y["full"] != [] }) }</td>
                </tr>
                <tr>
                  <th>Iwyu errors</th>
                  <td>${ len({x:y for x,y in items.items() if y["errors"] }) }</td>
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
            <div class="panel-heading">Full report
            </div>
            <div class="panel-body">
              <table class="table table-striped table-bordered table-condensed small">
                <thead>
                  <tr>
                    <th style="width:50px;"></th>
                    <th>File name</th>
                    <th>Error count</th>
                  </tr>
                </thead>
                <tbody>
                  % for c_file, c_data in sorted(items.items(), cmp=lambda x,y:cmp(x[0],y[0])):
                    <% css="warning" %>
                    % if c_data["errors"] == False:
                      <% css="success" %>
                      % if len(c_data["full"]):
                        <% css="danger" %>
                      % endif
                    % endif
                  <tr id="idm${loop.index}" class="${css}">
                    <td class="text-center">
                      % if css != "success":
                      <button class="btn btn-xs btn-primary glyphicon glyphicon-plus"></button>
                      % endif
                    </td>
                    <td>${c_file}</td>
                    % if css != "warning":
                    <td>${len(c_data["full"])}</td>
                    % else:
                    <td>err.</td>
                    % endif
                  </tr>
                  % if css != "success":
                  <tr id="idm${loop.index}-details" style="display: none;">
                    <td colspan="3">
                      % if css == "warning":
                      <pre style="max-height:300px; overflow:scroll;" class="small">
${ c_data["errors"] | h}
                      </pre>
                      % else:
                      <table class="table table-striped table-bordered table-condensed small">
                        <thead>
                          <tr>
                            <th style="width:33%">Full</th>
                            <th style="width:33%">Missing</th>
                            <th style="width:34%">Unwanted</th>
                          </tr>
                        </thead>
                        <tbody>
                          <tr>
                            <td>
                              <pre class="header small bg-info">
                          % for c_inc in c_data["full"]:
${c_inc | h}
                          % endfor
                              </pre>
                            </td>
                            <td>
                              <pre class="header small bg-warning">
                          % for c_inc in c_data["add"]:
${c_inc | h}
                          % endfor
                              </pre>
                            </td>
                            <td>
                              <pre class="header small bg-danger">
                          % for c_inc in c_data["rm"]:
${c_inc | h}
                          % endfor
                              </pre>
                            </td>
                          </tr>
                        </tbody>
                      </table>
                      % endif
                    </td>
                  </tr>
                  % endif
                  % endfor
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </body>
</html>
