package MaxImageWidth::Plugin;

use strict;

sub xfrm_asset_options {
    my ( $cb, $app, $tmpl ) = @_;
    my $slug;
    $slug = <<END_TMPL;
<link rel="stylesheet" type="text/css" href="<mt:StaticWebPath>plugins/MaxImageWidth/app.css" />
<link type="text/css" href="<mt:StaticWebPath>jquery/themes/flora/flora.all.css" rel="stylesheet" />
<script type="text/javascript" src="<mt:StaticWebPath>plugins/MaxImageWidth/jquery-1.3.2.min.js"></script>
<script type="text/javascript" src="<mt:StaticWebPath>plugins/MaxImageWidth/ui.core.js"></script>
<script type="text/javascript" src="<mt:StaticWebPath>plugins/MaxImageWidth/ui.slider.js"></script>
END_TMPL
    $$tmpl =~ s{(<mt:setvarblock name="html_head" append="1">)}{$1 $slug}msi;

}

sub asset_options_param {
    my ( $cb, $app, $param, $tmpl ) = @_;

    my $blog          = $app->blog;
    my $q             = $app->param;
    my $author        = $app->user;
    my $plugin        = MT->component('MaxImageWidth');
    my $config        = $plugin->get_config_hash( 'blog:' . $blog->id );
#    return if !$config->{supr_enable};

    my $max_width     = $config->{max_image_width};
    $max_width ||= $param->{width};

    my $ct_field = $tmpl->getElementById('create_thumbnail')
      or return $app->error('cannot get the create thumbnail block');
    my $new_field = $tmpl->createElement(
        'app:setting',
        {
            id    => 'create_thumbnail2',
            class => '',
            label => $app->translate("Use thumbnail"),
            label_class => "no-header",
            hint => "",
            show_hint => "0",
            help_page => "file_upload",
            help_section => "creating_thumbnails"
        }
    ) or return $app->error('cannot create the su_twitter element');
    my $mt = ($param->{make_thumb} ? 'checked="checked"' : '');
    my $html = <<HTML;
<script type="text/javascript">
    var full_width = $param->{width};
    var full_height = $param->{height};
    var max_width = $max_width;
    \$(document).ready( function() {
        \$('#thumb_width').change( function() {
            var new_w = \$(this).val();
            if (new_w > max_width) {
                \$(this).val( max_width );
            }
            \$('#thumb_height').val( Math.floor( (full_height * \$(this).val() ) / full_width) );
            \$('#width-slider').slider('option', 'value', \$(this).val());
        });
        \$('#thumb_height').change( function() {
            var new_h = \$(this).val();
            var new_w = Math.floor( (full_width * new_h ) / full_height );
            if (new_w > max_width) {
                \$('#thumb_width').val( max_width ).trigger('change');
                return;
            }
            \$('#thumb_width').val( new_w );
            \$('#width-slider').slider('option', 'value', new_w);
        });
        \$('#width-slider').slider({ 
          slide: function(event, ui) {
              \$('#thumb_width').val( ui.value );
              \$('#thumb_height').val( Math.floor( (full_height * ui.value ) / full_width) );
          },
          max: $param->{width} 
        });
        \$('#width-slider').slider('value', max_width);
    });
</script>
        <div id="create_thumbnail_cb">
          <input type="checkbox" name="thumb" id="create_thumbnail" value="1" $mt />
          <label for="create_thumbnail">Use thumbnail?</label>
        </div>
        <div id="w-h">
          <input type="text" id="thumb_width" size="3" name="thumb_width" value="$param->{width}" />
          x
          <input type="text" id="thumb_height" size="3" name="thumb_height" value="$param->{height}" />
        </div>
        <div id="width-slider"></div>
HTML
    $new_field->innerHTML($html);
    $tmpl->insertAfter( $new_field, $ct_field )
      or return $app->error('failed to insertAfter.');
    $ct_field->innerHTML('');

    $param;
}

1;
__END__
