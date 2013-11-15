<?php
$wgExtensionCredits['parserhook'][] = array(
    'name'         => 'WebServiceSequenceDiagram',
    'version'      => '1.0',
    'author'       => 'Adapted by Nick Townsend from an original by Eddie Olsson', 
    'url'          => 'http://www.mediawiki.org/wiki/Extension:WebSequenceDiagram',
    'description'  => 'Render inline sequence diagrams using websequencediagrams.com'
);
 
$wgHooks['ParserFirstCallInit'][] = 'webSequenceDiagramSetup';
 
if(!isset($wgWebSequenceServerURL)) {
    $wgWebSequenceServerURL = 'http://websequencediagrams.com';
}

function webSequenceDiagramSetup() {
    global $wgParser;
    $wgParser->setHook( 'sequencediagram', 'webSequenceDiagramRender' );
    return true;
}
 
function webSequenceDiagramRender( $input, $args, $parser) {
    global $wgWebSequenceServerURL;
    if( isset( $args['style'] ) )
	$style= $args['style'];
    else
	$style = 'default';

    $caption = '';
    if( isset( $args['caption'] ) )
	$caption = '<div class="thumbcaption">' . $args['caption'] . '</div>';

    return <<<OUT
<div class="thum tnone">
    <div class="thumbinner">
	<div class=wsd wsd_style="$style">
	<pre>
	$input
	</pre>
	</div>
	$caption
    </div>
</div>
<script type="text/javascript" src="$wgWebSequenceServerURL/service.js"></script>
OUT;

}
# vim: sts=4 sw=4 ts=8
?>
