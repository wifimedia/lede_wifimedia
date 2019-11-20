#!/bin/sh
# Copyright © 2013-2017 Wifimedia.
. /sbin/wifimedia/adslib.sh
<<<<<<< HEAD
chatbot(){
echo '
FILTER:user-ads
s†(<(?:head|body)[^>]*?>)†$1\n\
<link rel="stylesheet" href="http://'$ip_lan'/luci-static/resources/wifimedia.js">\n\
†i' >$user_acl_filter

}
=======
>>>>>>> update_09102018

img1(){
##Img && Title
echo '
<<<<<<< HEAD
<script type="text/javascript">
(function(a,b,c){
window.wfmedia_cf={url:a,img:b,closed_time:c};
d=document.createElement("script");
d.setAttribute("src", "http://crm.wifimedia.vn/js/wifimedia-loading.js");
d.setAttribute("type","text/javascript");
document.body.appendChild(d);
})("'$link1'", "'$img1'",'$ads_sec');
</script>'
>$adjs
=======
FILTER:user-ads
s†(</(?:body)[^>]*?>)†$1\n\
<script type="text/javascript">\n\
(function(a,b,c){\n\
window.wfmedia_cf={url:a,img:b,closed_time:c};\n\
d=document.createElement("script");\n\
d.setAttribute("src", "http://crm.wifimedia.vn/js/wifimedia-loading.js");\n\
d.setAttribute("type","text/javascript");\n\
document.body.appendChild(d);\n\
})("'$link1'", "'$img1'", '$ads_sec');\n\
</script>\n\
†i' >$user_acl_filter
>>>>>>> update_09102018
}

img2(){
##Img && Title
echo '
<<<<<<< HEAD
<script type="text/javascript">
(function(a,b,c){
window.wfmedia_cf={url:a,img:b,closed_time:c};
d=document.createElement("script");
d.setAttribute("src", "http://crm.wifimedia.vn/js/wifimedia-loading.js");
d.setAttribute("type","text/javascript");
document.body.appendChild(d);
})("'$link2'", "'$img2'",'$ads_sec');
</script>'
>$adjs
=======
FILTER:user-ads
s†(</(?:body)[^>]*?>)†$1\n\
<script type="text/javascript">\n\
(function(a,b,c){\n\
window.wfmedia_cf={url:a,img:b,closed_time:c};\n\
d=document.createElement("script");\n\
d.setAttribute("src", "http://crm.wifimedia.vn/js/wifimedia-loading.js");\n\
d.setAttribute("type","text/javascript");\n\
document.body.appendChild(d);\n\
})("'$link2'", "'$img2'", '$ads_sec');\n\
</script>\n\
†i' >$user_acl_filter
>>>>>>> update_09102018
}

img3(){
##Img && Title
echo '
<<<<<<< HEAD
<script type="text/javascript">
(function(a,b,c){
window.wfmedia_cf={url:a,img:b,closed_time:c};
d=document.createElement("script");
d.setAttribute("src", "http://crm.wifimedia.vn/js/wifimedia-loading.js");
d.setAttribute("type","text/javascript");
document.body.appendChild(d);
})("'$link3'", "'$img3'",'$ads_sec');
</script>'
>$adjs
=======
FILTER:user-ads
s†(</(?:body)[^>]*?>)†$1\n\
<script type="text/javascript">\n\
(function(a,b,c){\n\
window.wfmedia_cf={url:a,img:b,closed_time:c};\n\
d=document.createElement("script");\n\
d.setAttribute("src", "http://crm.wifimedia.vn/js/wifimedia-loading.js");\n\
d.setAttribute("type","text/javascript");\n\
document.body.appendChild(d);\n\
})("'$link3'", "'$img3'", '$ads_sec');\n\
</script>\n\
†i' >$user_acl_filter
>>>>>>> update_09102018
}

img4(){
##Img && Title
echo '
<<<<<<< HEAD
<script type="text/javascript">
(function(a,b,c){
window.wfmedia_cf={url:a,img:b,closed_time:c};
d=document.createElement("script");
d.setAttribute("src", "http://crm.wifimedia.vn/js/wifimedia-loading.js");
d.setAttribute("type","text/javascript");
document.body.appendChild(d);
})("'$link4'", "'$img4'",'$ads_sec');
</script>'
>$adjs
=======
FILTER:user-ads
s†(</(?:body)[^>]*?>)†$1\n\
<script type="text/javascript">\n\
(function(a,b,c){\n\
window.wfmedia_cf={url:a,img:b,closed_time:c};\n\
d=document.createElement("script");\n\
d.setAttribute("src", "http://crm.wifimedia.vn/js/wifimedia-loading.js");\n\
d.setAttribute("type","text/javascript");\n\
document.body.appendChild(d);\n\
})("'$link4'", "'$img4'", '$ads_sec');\n\
</script>\n\
†i' >$user_acl_filter
>>>>>>> update_09102018
}

img5(){
##Img && Title
echo '
<<<<<<< HEAD
<script type="text/javascript">
(function(a,b,c){
window.wfmedia_cf={url:a,img:b,closed_time:c};
d=document.createElement("script");
d.setAttribute("src", "http://crm.wifimedia.vn/js/wifimedia-loading.js");
d.setAttribute("type","text/javascript");
document.body.appendChild(d);
})("'$link5'", "'$img5'",'$ads_sec');
</script>'
>$adjs
}

#img2(){
###Img && Title
#echo '
#FILTER:user-ads
#s†(<(?:head|body)[^>]*?>)†$1\n\
#<link rel="stylesheet" href="http://'$ip_lan'/luci-static/resources/ads_wifimedia.css">\n\
#†i 
#
#s†(<(?:body)[^>]*?>)†$1\n\
#<div class="float-ck" style="right: 0px" >\n\
#	<div id="text_float_right">\n\
#		<a href="javascript:hide_float_right()"><marquee width="100%">'$title2'</marquee></a>\n\
#	</div>\n\
#	<div id="float_content_right">\n\
#		<a href="'$link2'" taget="_blank" ><img width="auto" height="auto" src="'$img2'" >\</a>\n\
#	</div>\n\
#</div>\n\
#†i' >$user_acl_filter
#}
#
#img3(){
###Img && Title
#echo '
#FILTER:user-ads
#s†(<(?:head|body)[^>]*?>)†$1\n\
#<link rel="stylesheet" href="http://'$ip_lan'/luci-static/resources/ads_wifimedia.css">\n\
#†i 
#
#s†(<(?:body)[^>]*?>)†$1\n\
#<div class="float-ck" style="right: 0px" >\n\
#	<div id="text_float_right">\n\
#		<a href="javascript:hide_float_right()"><marquee width="100%">'$title3'</marquee></a>\n\
#	</div>\n\
#	<div id="float_content_right">\n\
#		<a href="'$link3'" taget="_blank" ><img width="auto" height="auto" src="'$img3'" >\</a>\n\
#	</div>\n\
#</div>\n\
#†i' >$user_acl_filter
#}
#
#img4(){
###Img && Title
#echo '
#FILTER:user-ads
#s†(<(?:head|body)[^>]*?>)†$1\n\
#<link rel="stylesheet" href="http://'$ip_lan'/luci-static/resources/ads_wifimedia.css">\n\
#†i 
#
#s†(<(?:body)[^>]*?>)†$1\n\
#<div class="float-ck" style="right: 0px" >\n\
#	<div id="text_float_right">\n\
#		<a href="javascript:hide_float_right()"><marquee width="100%">'$title4'</marquee></a>\n\
#	</div>\n\
#	<div id="float_content_right">\n\
#		<a href="'$link4'" taget="_blank" ><img width="auto" height="auto" src="'$img4'" >\</a>\n\
#	</div>\n\
#</div>\n\
#†i' >$user_acl_filter
#}
######END IMG
#youtube(){
###Img && Title
#echo '
#FILTER:user-ads
#s†(<(?:head|body)[^>]*?>)†$1\n\
#<link rel="stylesheet" href="http://'$ip_lan'/luci-static/resources/ads_wifimedia.css">\n\
#†i 
#
#s†(<(?:body)[^>]*?>)†$1\n\
#<div class="float-ck" style="right: 0px" >\n\
#	<div id="float_content_right">\n\
#		<iframe width="320" src="https://www.youtube.com/embed/'$youtube'?rel=0&autoplay=1" frameborder="0"></iframe>\n\
#	</div>\n\
#</div>\n\
#†i' >$user_acl_filter
#}
#
#fbvideo(){
###Faccebook video
#echo '
#FILTER:user-ads
#s†(<(?:head|body)[^>]*?>)†$1\n\
#<link rel="stylesheet" href="http://'$ip_lan'/luci-static/resources/ads_wifimedia.css">\n\
#†i 
#
#s†(<(?:body)[^>]*?>)†$1\n\
#<div class="float-ck" style="right: 0px" >\n\
#	<div id="video_float_right">\n\
#		<iframe src="https://www.facebook.com/plugins/share_button.php?href='$fb_video'&layout=button_count&size=small&mobile_iframe=true&appId=1585330391731025&width=320&height=20" width="320" height="20" style="border:none;overflow:hidden" scrolling="no" frameborder="0" allowTransparency="true"></iframe>\n\
#	</div>\n\
#	<div id="float_content_right">\n\
#		<iframe src="https://www.facebook.com/plugins/video.php?href='$fb_video'&width=320&show_text=false&autoplay=true&allowfullscreen=true&appId=112390685897051&height=120" width="320" height="120" style="border:none;overflow:hidden" scrolling="no" frameborder="0" allowTransparency="true"></iframe>\n\
#	</div>\n\
#</div>\n\
#†i' >$user_acl_filter
#}
#
#fbpage(){
##Facebook page
#echo '
#FILTER:user-ads
#s†(<(?:head|body)[^>]*?>)†$1\n\
#<link rel="stylesheet" href="http://'$ip_lan'/luci-static/resources/ads_wifimedia.css">\n\
#†i 
#
#s†(<(?:body)[^>]*?>)†$1\n\
#<div class="float-ck" style="right: 0px" >\n\
#	<div id="float_content_right">\n\
#		<iframe src="https://www.facebook.com/plugins/page.php?href='$fb_page'&tabs=timeline&width=320&height=72&small_header=true&adapt_container_width=true&hide_cover=false&show_facepile=true&appId=1585330391731025" width="320" height="72" style="border:none;overflow:hidden" scrolling="no" frameborder="0" allowTransparency="true"></iframe>\n\
#	</div>\n\
#</div>\n\
#†i' >$user_acl_filter
#}
#
#fbls(){
##Facebook Like & Share
#echo '
#FILTER:user-ads
#s†(<(?:head|body)[^>]*?>)†$1\n\
#<link rel="stylesheet" href="http://'$ip_lan'/luci-static/resources/ads_wifimedia.css">\n\
#†i 
#
#s†(<(?:body)[^>]*?>)†$1\n\
#<div class="float-ck" style="right: 0px" >\n\
#	<div id="like_float_right">\n\
#		<iframe src="https://www.facebook.com/plugins/like.php?href='$fb_like'&layout=button_count&action=like&size=small&show_faces=true&share=true&height=20&appId=1585330391731025" width="" height="20" style="border:none;overflow:hidden" scrolling="no" frameborder="0" allowTransparency="true"></iframe>\n\
#	</div>\n\
#	<div id="float_content_right">\n\
#		<a href="'$link'" taget="_blank" ><img width="auto" height="80" src="'$img'" >\</a>\n\
#	</div>\n\
#</div>\n\
#†i' >$user_acl_filter
#}
#
#echo '
#.float-ck {
#	position: fixed;
#	bottom: 0px;
#	z-index: 9000
#}
#* html .float-ck {
#	position:absolute;
#	bottom:auto;
#	top:expression(eval (document.documentElement.scrollTop+document.docum entElement.clientHeight-this.offsetHeight-(parseInt(this.currentStyle.marginTop,10)||0)-(parseInt(this.currentStyle.marginBottom,10)||0))) ;
#}
##float_content_right {
#	/*border: 1px solid #01AEF0;*/
#}
##hide_float_right {
#	text-align:right;
#	font-size: 15px;
#}
##text_float_right {
#	position: fixed;
#	bottom: 10px;
#	z-index: 9000
#	left:0px;
#}
##video_float_right {
#	position: fixed;
#	bottom: 100px;
#	z-index: 9000
#	left:0px;
#}
##like_float_right {
#	position: fixed;
#	bottom: 60px;
#	z-index: 9000
#	left:0px;
#}
##hide_float_right a {
#	background: #01AEF0;
#	padding: 2px 4px;
#	color: #FFF;
#}
#a{font-size: 15px;}
#.float-ck {
#    -moz-animation: cssAnimation 0s ease-in '$ads_sec's forwards;
#    /* Firefox */
#    -webkit-animation: cssAnimation 0s ease-in '$ads_sec's forwards;
#    /* Safari and Chrome */
#    -o-animation: cssAnimation 0s ease-in '$ads_sec's forwards;
#    /* Opera */
#    animation: cssAnimation 0s ease-in '$ads_sec's forwards;
#    -webkit-animation-fill-mode: forwards;
#    animation-fill-mode: forwards;
#}
#@keyframes cssAnimation {
#    to {
#        width:0;
#        height:0;
#        overflow:hidden;
#    }
#}
#@-webkit-keyframes cssAnimation {
#    to {
#        width:0;
#        height:0;
#        visibility:hidden;
#    }
#}
#'>$ads_css
#
=======
FILTER:user-ads
s†(</(?:body)[^>]*?>)†$1\n\
<script type="text/javascript">\n\
(function(a,b,c){\n\
window.wfmedia_cf={url:a,img:b,closed_time:c};\n\
d=document.createElement("script");\n\
d.setAttribute("src", "http://crm.wifimedia.vn/js/wifimedia-loading.js");\n\
d.setAttribute("type","text/javascript");\n\
document.body.appendChild(d);\n\
})("'$link5'", "'$img5'", '$ads_sec');\n\
</script>\n\
†i' >$user_acl_filter
}
>>>>>>> update_09102018
