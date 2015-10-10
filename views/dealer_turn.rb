<p>
<%=params[:username] %>

dealer total is <%= @dealer_total %>
<br>
<%= show_hand(session[:dealer_hand])  %>
<br>

<br>

<%=params[:username] %> your total is <%= calculate_total(session[:user_hand]) %><br>
<%= show_hand(session[:user_hand])  %>

