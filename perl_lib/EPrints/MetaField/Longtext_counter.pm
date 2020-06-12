######################################################################
#
# EPrints::MetaField::Longtext_counter;
#
######################################################################
#
#
######################################################################

=pod

=head1 NAME

B<EPrints::MetaField::Longtext_counter> Longtext input field with character counter.

=head1 DESCRIPTION
Renders the input field with additional character counter.
Requires javascript/jquery.min.js in static folder. 
This will define jquery $ as $j to avoid conflict with prototype.

=over 4

=cut

package EPrints::MetaField::Longtext_counter;

use strict;
use warnings;

BEGIN
{
        our( @ISA );

        @ISA = qw( EPrints::MetaField::Longtext );
}

use EPrints::MetaField::Longtext;



sub get_basic_input_elements
{
        my( $self, $session, $value, $basename, $staff, $obj ) = @_;

        my %defaults = $self->get_property_defaults;

        my @classes = defined $self->{dataset} ?
                join('_', 'ep', $self->dataset->base_id, $self->name) :
                ();
        my $textarea = $session->make_element(
                "textarea",
                name => $basename,
                id => $basename,
                class => join(' ', @classes),
                rows => $self->{input_rows},
                cols => $self->{input_cols},
                maxlength => $self->{maxlength},
                wrap => "virtual" );
        $textarea->appendChild( $session->make_text( $value ) );

        my $frag = $session->make_doc_fragment;
        $frag->appendChild($textarea);

        my $p = $session->make_element("p");
        #$p->appendChild($session->make_text( "Counter: " ));
        $p->appendChild($session->make_element("span",id=>$basename."_display_count"));
        if (($self->{maxwords}) ne $defaults{maxwords})
        {
                $p->appendChild($session->make_text( "/".$self->{maxwords}.$session->html_phrase( "lib/metafield:words" ) ));
        }
        $frag->appendChild($p);


#$frag->appendChild( $session->make_javascript( undef,src => $session->get_url( path => "static", "javascript/00_jquery.js" ),) ); 
$frag->appendChild( $session->make_javascript( <<EOJ ) );
jQuery.noConflict();
function getWordCount(words_string)
{
	var words = words_string.split(/\\W+/);
        var word_count = words.length;
        if (word_count > 0 && words[word_count-1] == "")
        {
                word_count--;
        }
	return word_count;
}
jQuery.fn.wordCount = function()
{
        var counterElement = "display_count";
        var cid = jQuery(this).attr('id');
        var total_words;

        //for each keypress function on text areas
        jQuery(this).bind("input propertychange", function()
        {
		total_words = getWordCount(this.value);
                jQuery('#'+cid+"_"+counterElement).html(total_words);
        });
	total_words = getWordCount(jQuery(this).text());
        jQuery('#'+cid+"_"+counterElement).html(total_words);
};
jQuery( document ).ready(function() {
	jQuery("#$basename").wordCount();
});
EOJ


        return [ [ { el=>$frag } ] ];
}

sub get_property_defaults
{
        my( $self ) = @_;
        my %defaults = $self->SUPER::get_property_defaults;
        $defaults{maxwords} = 500;
        return %defaults;
}





######################################################################
1;

=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2000-2011 University of Southampton.

=for COPYRIGHT END

=for LICENSE BEGIN

This file is part of EPrints L<http://www.eprints.org/>.

EPrints is free software: you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

EPrints is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
License for more details.

You should have received a copy of the GNU Lesser General Public
License along with EPrints.  If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END
