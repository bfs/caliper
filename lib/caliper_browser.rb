class CaliperBrowser
  require 'capybara/dsl'
  
  include Capybara::DSL
      
  def initialize
    headless = Headless.new
    headless.start
    Capybara.default_driver = :webkit
  end
    
  def get_page(url)
    visit(url)
    cram_in_jquery!
  end
  def load_string(str)
    cram_in_jquery!
    populate_script = <<-EOS
      $('body').append($('<form id="hackedyHack"/>'));
      $('#hackedyHack').append($('<textarea id="contentHolder" name="contentHolder"></textarea>'));
    EOS
    page.execute_script(populate_script)
    within("#hackedyHack") do
     fill_in('contentHolder', :with=>str)
    end
    replace_script = <<-EOS
      $('html').html($('#contentHolder').val());
    EOS
    page.execute_script(replace_script)
    cram_in_jquery!
  end
      
  def get_measurements
    apply_measure_scripts
    find('#calipermeasurements').text
  end
  
  
  private
  def cram_in_jquery!
    begin
      
      jquery_add_script = <<-EOS
      function addMeasurementContainer(){
        var $measurements = $('<div id="calipermeasurements"></div>');
        $('body').append($measurements);
      }

      if (typeof jQuery != 'undefined') {
        addMeasurementContainer();
      }
      else{
        var head = document.getElementsByTagName("head")[0];         
        var jqs = document.createElement('script');
        jqs.id = "fjquery";
        jqs.type = 'text/javascript';
        jqs.onload=addMeasurementContainer;
        jqs.src = 'http://ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js';
        head.appendChild(jqs);
      }

      
      EOS

      page.execute_script(jquery_add_script)
      warn page.has_css?('#calipermeasurements')
      
    #rescue Capybara::Driver::Webkit::WebkitInvalidResponseError
    #  warn "FAILED!!"
    end
  end
  
  def apply_measure_scripts
    measure_script = <<-EOS
      function getXPath(elm) {
        for (segs = []; elm && elm.nodeType == 1; elm = elm.parentNode) {
          if (elm.hasAttribute('id')) {
            segs.unshift('id("' + elm.getAttribute('id') + '")')
            return segs.join('/')
          }
          else if (elm.hasAttribute('class'))
            segs.unshift(elm.localName.toLowerCase() + '[@class="' + elm.getAttribute('class') + '"]')
          else {
            for (i = 1, sib = elm.previousSibling; sib; sib = sib.previousSibling)
              if (sib.localName == elm.localName) i++
            segs.unshift(elm.localName.toLowerCase() + '[' + i + ']')
          }
        }
        return segs.length ? '/' + segs.join('/') : null
        }

        function doMeasurements(){
          var m = {};
          $('*').each(function(idx,el){
            var pos = $(el).position();
            var w = $(el).width();
            var h = $(el).height();
            if (pos.left>0 && pos.top>0 && w>0 && h>0)
              m[getXPath(el)] =  {x:pos.left, y:pos.top, w:w, h:h};
          });
          $('#calipermeasurements').html(JSON.stringify(m));
        }

        doMeasurements();
      EOS
      
      page.execute_script(measure_script)
  end
  
  

      
end