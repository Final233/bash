<%@page import="java.util.Enumeration"%>
<br />
host: <%try{out.println(""+java.net.InetAddress.getLocalHost().getHostName());}catch(Exception e){}%>
<br />
	remoteAddr: <%=request.getRemoteAddr()%>
<br />
	remoteHost: <%=request.getRemoteHost()%>
<br />
	sessionId: <%=request.getSession().getId()%>
<br />
	serverName:<%=request.getServerName()%>
<br />
	scheme:<%=request.getScheme()%>
<br />
	<%request.getSession().setAttribute("t1","t2");%>
<%
	Enumeration en = request.getHeaderNames();
	while(en.hasMoreElements()){
	String hd = en.nextElement().toString();
	out.println(hd+" : "+request.getHeader(hd));
	out.println("<br />");
	}
%>
