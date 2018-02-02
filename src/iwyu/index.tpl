<%def name="header(loop, color, name, key, data)">
<tr class="idm${loop.index}-details header" style="display: none;">
  <td></td>
  <td class="${color}" colspan="4">
    <div class="text-center"><strong>${name}</strong></div>
    <pre class="includes ${color}">
                      % for c_inc in data[key]:
${c_inc.strip() | h}
                      % endfor
</pre>
  </td>
</tr>
</%def>

<%def name="headersplit(loop, color, name, key, data)">
<tr class="idm${loop.index}-details hidden header-split" style="display: none;">
  <td></td>
  <td class="${color}" colspan="2">
    <div class="text-center"><strong>${name}</strong></div>
    <pre class="includes ${color}">
                      % for c_inc in data[key]:
${c_inc.split("//")[0].strip() | h}
                      % endfor
</pre>
  </td>
  <td class="${color}" colspan="2">
    <div class="text-center"><strong>${name}</strong></div>
    <pre class="includes ${color}">
                      % for c_inc in data[key]:
                      % if "//" in c_inc:
// ${c_inc.split("//")[1].strip() | h}
                      % else:

                      % endif
                      % endfor
</pre>
  </td>
</tr>
</%def>


<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Include sanity report</title>
    <link href="../../contribs/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <link href="../../contribs/bootstrap/css/bootstrap-theme.min.css" rel="stylesheet">
    <script src="../../contribs/jquery/jquery.min.js"></script>
    <script src="../../contribs/bootstrap/js/bootstrap.min.js"></script>
    <script type="text/javascript">
     function SelectText(text) {
       var doc = document,
           range, selection
       ;
       if (doc.body.createTextRange) {
         range = document.body.createTextRange();
         range.moveToElementText(text);
         range.select();
       } else if (window.getSelection) {
         selection = window.getSelection();
         range = document.createRange();
         range.selectNodeContents(text);
         selection.removeAllRanges();
         selection.addRange(range);
       }
     }
     $(document).ready(function() {
       $("button.open").click(function() {
         var l_tr        = $(this).parents("tr");
         var l_id        = l_tr.attr("id");
         var l_detailsID = l_id + "-details";
         $("." + l_detailsID).toggle();
       });
       $("pre").dblclick(function() {
         SelectText($(this)[0]);
       });
       $("#split").click(function() {
         $(".header").toggleClass("hidden");
         $(".header-split").toggleClass("hidden");
       });
     });
    </script>
    <style>

     .includes {
       overflow: scroll;
       font-size:10px;
     }

     .maintable {
       table-layout:fixed;
     }

    </style>
  </head>
  <body bgcolor="#ffffff" style="padding-top:50px;">
    <div class="container-fluid">
      <div class="row">
        <div class="col-lg-4 col-lg-offset-4"><div class="panel panel-default">
          <div class="panel-heading">Summary report</div>
          <div class="panel-body">
            <table class="table table-bordered table-condensed small">
              <tbody>
                <tr>
                  <th>Analyzed files</th>
                  <td>${len(items)}</td>
                </tr>
                <tr>
                  <th>Files Ok</th>
                  <td>${ len({x:y for x,y in items.items() if y["errors"] == False and y["full"] == [] }) }</td>
                </tr>
                <tr>
                  <th>Files Ko</th>
                  <td>${ len({x:y for x,y in items.items() if y["errors"] == False and y["full"] != [] }) }</td>
                </tr>
                <tr>
                  <th>Iwyu errors</th>
                  <td>${ len({x:y for x,y in items.items() if y["errors"] }) }</td>
                </tr>
                <tr class="bg-warning">
                  <th>(from Ko files) Missing includes</th>
                  <td>${ sum([ len(items[x]["add"]) for x in items ]) }</td>
                </tr>
                <tr class="bg-danger">
                  <th>(from Ko files) Unwanted includes</th>
                  <td>${ sum([ len(items[x]["rm"]) for x in items ]) }</td>
                </tr>
                <tr class="bg-info">
                  <th>(from Ko files) Total includes</th>
                  <td>${ sum([ len(items[x]["full"]) for x in items ]) }</td>
                </tr>
                <tr>
                  <td colspan="2" class="text-center">
                    <button id="split" type="button" class="btn btn-primary" data-toggle="button" aria-pressed="false" autocomplete="off">
                      Split comments
                    </button>
                  </td>
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
              <table class="maintable table table-striped table-bordered table-condensed small">
                <thead>
                  <tr>
                    <th style="width:50px;"></th>
                    <th>File name</th>
                    <th>Missing</th>
                    <th>Unwanted</th>
                    <th>Total</th>
                  </tr>
                </thead>
                <tbody>
                  <%
                  l_base = list(items.keys())[0]
                  while len(l_base):
                    l_found=True
                    for c_file in items.keys():
                      if not c_file.startswith(l_base):
                        l_found=False
                        break
                    if l_found:
                      l_base += "/"
                      break
                    l_base = "/".join(l_base.split("/")[:-1])
                  %>
                  % for c_file, c_data in sorted(items.items(), key=lambda x: x[0]):
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
                      <button class="open btn btn-xs btn-primary glyphicon glyphicon-plus"></button>
                      % endif
                    </td>
                    <td> ${ c_file.replace(l_base, "") } </td>
                    % if css != "warning":
                    <td>${len(c_data["add"])}</td>
                    <td>${len(c_data["rm"])}</td>
                    <td>${len(c_data["full"])}</td>
                    % else:
                    <td>err.</td>
                    <td>err.</td>
                    <td>err.</td>
                    % endif
                  </tr>

                  % if css == "warning":
                  <tr class="idm${loop.index}-details" style="display: none;">
                    <td></td>
                    <td colspan="4">
                      <pre class="includes bg-warning">
${c_data["errors"] | h}
                      </pre>
                    </td>
                  </tr>
                  % else:
                  ${header(loop=loop, color="bg-info",    name="Full",     key="full", data=c_data)}
                  ${header(loop=loop, color="bg-warning", name="Missing",  key="add",  data=c_data)}
                  ${header(loop=loop, color="bg-danger",  name="Unwanted", key="rm",   data=c_data)}
                  ${headersplit(loop=loop, color="bg-info",    name="Full",     key="full", data=c_data)}
                  ${headersplit(loop=loop, color="bg-warning", name="Missing",  key="add",  data=c_data)}
                  ${headersplit(loop=loop, color="bg-danger",  name="Unwanted", key="rm",   data=c_data)}
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
