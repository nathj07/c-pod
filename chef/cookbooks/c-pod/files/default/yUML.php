<?php
$wgExtensionCredits['parserhook'][] = array(
    'name'         => 'yUML',
    'version'      => '1.0',
    'author'       => 'Adapted by Nick Townsend', 
    'url'          => 'http://www.mediawiki.org/wiki/Extension:yUML',
    'description'  => 'Render inline UML diagrams using yUML.me'
);

$wgHooks['ParserFirstCallInit'][] = 'efYUMLInit';

if(!isset($wgYUMLServerURL)) {
    $wgYUMLServerURL = 'http://yuml.me';
}

function efYUMLInit() {
    global $wgParser;
    $wgParser->setHook( 'classdiagram', 'efClassdiagramRender' );
    $wgParser->setHook( 'usecase', 'efUsecaseRender' );
    $wgParser->setHook( 'activity', 'efActivityRender' );
    $GLOBALS['wgYUMLimg'] = 'yuml0';
    return true;
}

function yUMLRenderDiagram( $input, $args, $type, $parser, $frame ) {
    global $wgYUMLServerURL;
    //$parser->disableCache();

    $theme = ";";
    if(isset($args['theme'])){
	$theme = $args["theme"];
    }
    $scale = "";
    if(isset($args['scale'])){
	$scale=";scale:".$args["scale"];
    }
    $dir = "";
    if(isset($args['dir'])){
	$dir=";dir:".$args["dir"];
    }
    $customizations = "$theme$scale$dir";

    $uml_text = preg_replace(
	array("/(\n|\r|\t)+/", "/,,/"),
	array(", ",   ","   ),
	trim($input));
    $img = $GLOBALS['wgYUMLimg'];
    $output = ($img != 'yuml0') ? '':  <<<CODESTUFF
<script>
function encodeURICustom(dsl){
  tmp = encodeURI(dsl);
  tmp = tmp.replace(/#/g,'%23')
  return tmp;
}
function buildUrl(baseurl,img_field,type_text, cust_text, dsl_text){
  var method = dsl_text.length > 200 ? 'POST' : 'GET';
  var template = "[BASE]/diagram/[CUST]/[TYPE]/";
  var output = template.replace('[BASE]',baseurl).replace('[CUST]',cust_text).replace('[TYPE]',type_text);
  if(method=='GET'){
    output = output + dsl_text;
    $(img_field).attr('src',encodeURICustom(output));
  }
  else{
    var src = $.ajax({
      type: "POST",
      url: output,
      crossDomain: true,
      data:{dsl_text: dsl_text},
      async: false
    }).responseText;
    $(img_field).attr('src',baseurl+'/'+src);
  }
  return false
}
</script>
CODESTUFF;

    $output .= <<<IMAGE
<img id="$img"/>
<script>$(document).ready(buildUrl('$wgYUMLServerURL','#$img','$type','$customizations','$uml_text'));</script>
IMAGE;

    $GLOBALS['wgYUMLimg']++;
    return array($output, "markerType" => 'nowiki' );
}

function efClassdiagramRender( $input, $args, $parser, $frame ) {
    return yUMLRenderDiagram( $input, $args, "class", $parser, $frame );
}
function efUsecaseRender( $input, $args, $parser, $frame ) {
    return yUMLRenderDiagram( $input, $args, "usecase", $parser, $frame );
}
function efActivityRender( $input, $args, $parser, $frame ) {
    return yUMLRenderDiagram( $input, $args, "activity", $parser, $frame );
}

# vim: sts=4 sw=4 ts=8
?>
