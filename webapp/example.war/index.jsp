<html>
  <head><title>Session Tracking Test</title>
</head>
    <body>
    <h1>Session Tracking Test</h1>
    Session tracking with JSP is easy
    <P>
<%@ page session="true" %>
<%
      // Get the session data value
    Integer ival = (Integer) session.getValue ("counter");
if (ival == null) ival = new Integer (1);
else ival = new Integer (ival.intValue() + 1);
session.putValue ("counter", ival);
%>
    You have hit this page <%= ival %> times.<br>
<%
    out.println("Your Session ID is " + session.getId() +  "<br>");
    System.out.println("session=" + session.getId());
%>		 
</body></html>

