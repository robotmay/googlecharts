require File.dirname(__FILE__) + '/spec_helper.rb'
require File.dirname(__FILE__) + '/../lib/gchart'

Gchart::Theme.add_theme_file("#{File.dirname(__FILE__)}/fixtures/test_theme.yml")

# Time to add your specs!
# http://rspec.rubyforge.org/
describe "The Gchart::Base class" do
  it "should show supported_types on error" do
    Gchart::Base.supported_types.should match(/line/)
  end

  it "should return supported types" do
    Gchart::Base.types.should include('line')
  end

  it "should support theme option" do
    chart = Gchart::Base.new(:type => 'line',:theme => :test)
    chart.send('url').should include('chco=6886B4,FDD84E')
  end
end

describe "generating a default Gchart::Base" do

  before(:each) do
    @chart = Gchart::Base.line
  end

  it "should create a line break when a pipe character is encountered" do
    @chart = Gchart::Base.line(:title => "title|subtitle")	
    @chart.should include("chtt=title\nsubtitle")
  end

  it "should include the Google URL" do
    @chart.should include("http://chart.apis.google.com/chart?")
  end

  it "should have a default size" do
    @chart.should include('chs=300x200')
  end

  it "should be able to have a custom size" do
    Gchart::Base.line(:size => '400x600').should include('chs=400x600')
    Gchart::Base.line(:width => 400, :height => 600).should include('chs=400x600')
  end

  it "should have query parameters in predictable order" do
    Gchart::Base.line(:axis_with_labels => 'x,y,r', :size => '400x600').should match(/chxt=.+cht=.+chs=/)
  end

  it "should have a type" do
    @chart.should include('cht=lc')
  end

  it 'should use theme defaults if theme is set' do
    Gchart::Base.line(:theme=>:test).should include('chco=6886B4,FDD84E')
    Gchart::Base.line(:theme=>:test).should match(/chf=(c,s,FFFFFF\|bg,s,FFFFFF|bg,s,FFFFFF\|c,s,FFFFFF)/)
  end

  it "should use the simple encoding by default with auto max value" do
    # 9 is the max value in simple encoding, 26 being our max value the 2nd encoded value should be 9
    Gchart::Base.line(:data => [0, 26]).should include('chd=s:A9')
    Gchart::Base.line(:data => [0, 26], :max_value => 26, :axis_with_labels => 'y').should include('chxr=0,0,26')
  end

  it "should support simple encoding with and without max_value" do
    Gchart::Base.line(:data => [0, 26], :max_value => 26).should include('chd=s:A9')
    Gchart::Base.line(:data => [0, 26], :max_value => false).should include('chd=s:Aa')
  end

  it "should support the extended encoding and encode properly" do
    Gchart::Base.line(:data => [0, 10], :encoding => 'extended', :max_value => false).should include('chd=e:AA')
    Gchart::Base.line(:encoding => 'extended',
                :max_value => false,
                :data => [[0,25,26,51,52,61,62,63], [64,89,90,115,4084]]
                ).should include('chd=e:AAAZAaAzA0A9A-A.,BABZBaBz.0')
  end

  it "should auto set the max value for extended encoding" do
    Gchart::Base.line(:data => [0, 25], :encoding => 'extended', :max_value => false).should include('chd=e:AAAZ')
    # Extended encoding max value is '..'
    Gchart::Base.line(:data => [0, 25], :encoding => 'extended').should include('chd=e:AA..')
  end

  it "should be able to have data with text encoding" do
    Gchart::Base.line(:data => [10, 5.2, 4, 45, 78], :encoding => 'text').should include('chd=t:10,5.2,4,45,78')
  end

  it "should be able to have missing data points with text encoding" do
    Gchart::Base.line(:data => [10, 5.2, nil, 45, 78], :encoding => 'text').should include('chd=t:10,5.2,_,45,78')
  end

  it "should handle max and min values with text encoding" do
    Gchart::Base.line(:data => [10, 5.2, 4, 45, 78], :encoding => 'text').should include('chds=0,78')
  end

  it "should automatically handle negative values with proper max/min limits when using text encoding" do
    Gchart::Base.line(:data => [-10, 5.2, 4, 45, 78], :encoding => 'text').should include('chds=-10,78')
  end

  it "should handle negative values with manual max/min limits when using text encoding" do
   Gchart::Base.line(:data => [-10, 5.2, 4, 45, 78], :encoding => 'text', :min_value => -20, :max_value => 100).should include('chds=-20,100')
  end

  it "should set the proper axis values when using text encoding and negative values" do
    Gchart::Base.bar( :data       => [[-10], [100]],
                :encoding   => 'text',
                :horizontal => true,
                :min_value  => -20,
                :max_value  => 100,
                :axis_with_labels => 'x',
                :bar_colors => ['FD9A3B', '4BC7DC']).should include("chxr=0,-20,100")
  end

  it "should be able to have multiple set of data with text encoding" do
    Gchart::Base.line(:data => [[10, 5.2, 4, 45, 78], [20, 40, 70, 15, 99]], :encoding => 'text').should include(Gchart::Base.jstize('chd=t:10,5.2,4,45,78|20,40,70,15,99'))
  end

  it "should be able to receive a custom param" do
    Gchart::Base.line(:custom => 'ceci_est_une_pipe').should include('ceci_est_une_pipe')
  end

  it "should be able to set label axis" do
    Gchart::Base.line(:axis_with_labels => 'x,y,r').should include('chxt=x,y,r')
    Gchart::Base.line(:axis_with_labels => ['x','y','r']).should include('chxt=x,y,r')
  end

  it "should be able to have axis labels" do
   Gchart::Base.line(:axis_labels => ['Jan|July|Jan|July|Jan', '0|100', 'A|B|C', '2005|2006|2007']).should include(Gchart::Base.jstize('chxl=0:|Jan|July|Jan|July|Jan|1:|0|100|2:|A|B|C|3:|2005|2006|2007'))
   Gchart::Base.line(:axis_labels => ['Jan|July|Jan|July|Jan']).should include(Gchart::Base.jstize('chxl=0:|Jan|July|Jan|July|Jan'))
   Gchart::Base.line(:axis_labels => [['Jan','July','Jan','July','Jan']]).should include(Gchart::Base.jstize('chxl=0:|Jan|July|Jan|July|Jan'))
   Gchart::Base.line(:axis_labels => [['Jan','July','Jan','July','Jan'], ['0','100'], ['A','B','C'], ['2005','2006','2007']]).should include(Gchart::Base.jstize('chxl=0:|Jan|July|Jan|July|Jan|1:|0|100|2:|A|B|C|3:|2005|2006|2007'))
  end

  def labeled_line(options = {})
    Gchart::Base.line({:data => @data, :axis_with_labels => 'x,y'}.merge(options))
  end

  it "should display ranges properly" do
    @data = [85,107,123,131,155,172,173,189,203,222,217,233,250,239,256,267,247,261,275,295,288,305,322,307,325,347,331,346,363,382,343,359,383,352,374,393,358,379,396,416,377,398,419,380,409,426,453,432,452,465,436,460,480,440,457,474,501,457,489,507,347,373,413,402,424,448,475,488,513,475,507,530,440,476,500,518,481,512,531,367,396,423,387,415,446,478,442,469,492,463,489,508,463,491,518,549,503,526,547,493,530,549,493,520,541,564,510,535,564,492,512,537,502,530,548,491,514,538,568,524,548,568,512,533,552,577,520,545,570,516,536,555,514,536,566,521,553,579,604,541,569,595,551,581,602,549,576,606,631,589,615,650,597,624,646,672,605,626,654,584,608,631,574,597,622,559,591,614,644,580,603,629,584,615,631,558,591,618,641,314,356,395,397,429,450,421,454,477,507,458,490,560,593]
    labeled_line(:axis_labels => [((1..24).to_a << 1)]).
      should include('chxr=0,85,672')
  end

  def labeled_bar(options = {})
    Gchart::Base.bar({:data => @data,
            :axis_with_labels => 'x,y',
            :axis_labels => [(1..12).to_a],
            :encoding => "text"
    }.merge(options))
  end

  it "should force the y range properly" do
    @data = [1,1,1,1,1,1,1,1,6,2,1,1]
    labeled_bar(
      :axis_range => [[0,0],[0,16]]
    ).should include('chxr=0,0,0|1,0,16')
    labeled_bar(
      :max_value => 16,
      :axis_range => [[0,0],[0,16]]
    ).should include('chxr=0,0,16|1,0,16')

    # nil means ignore axis
    labeled_bar(
      :axis_range => [nil,[0,16]]
    ).should include('chxr=1,0,16')

    # empty array means take defaults
    labeled_bar(
      :max_value => 16,
      :axis_range => [[],[0,16]]
    ).should include('chxr=0,0,16|1,0,16')
    labeled_bar(
      :axis_range => [[],[0,16]]
    ).should include('chxr=0,0|1,0,16')

    Gchart::Base.line(
            :data => [0,20, 40, 60, 140, 230, 60],
            :axis_with_labels => 'y').should include("chxr=0,0,230")
  end

  it "should take in consideration the max value when creating a range" do
    data = [85,107,123,131,155,172,173,189,203,222,217,233,250,239,256,267,247,261,275,295,288,305,322,307,325,347,331,346,363,382,343,359,383,352,374,393,358,379,396,416,377,398,419,380,409,426,453,432,452,465,436,460,480,440,457,474,501,457,489,507,347,373,413,402,424,448,475,488,513,475,507,530,440,476,500,518,481,512,531,367,396,423,387,415,446,478,442,469,492,463,489,508,463,491,518,549,503,526,547,493,530,549,493,520,541,564,510,535,564,492,512,537,502,530,548,491,514,538,568,524,548,568,512,533,552,577,520,545,570,516,536,555,514,536,566,521,553,579,604,541,569,595,551,581,602,549,576,606,631,589,615,650,597,624,646,672,605,626,654,584,608,631,574,597,622,559,591,614,644,580,603,629,584,615,631,558,591,618,641,314,356,395,397,429,450,421,454,477,507,458,490,560,593]
    url = Gchart::Base.line(:data => data, :axis_with_labels => 'x,y', :axis_labels => [((1..24).to_a << 1)], :max_value => 700)
    url.should include('chxr=0,85,700')
  end

  it 'should generate different labels and legend' do
    Gchart::Base.pie(:legend => %w(1 2 3), :labels=>%w(one two three)).should(include('chdl=1|2|3') && include('chl=one|two|three'))
  end
end

describe "generating different type of charts" do

  it "should be able to generate a line chart" do
    Gchart::Base.line.should be_an_instance_of(String)
    Gchart::Base.line.should include('cht=lc')
  end

  it "should be able to generate a sparkline chart" do
    Gchart::Base.sparkline.should be_an_instance_of(String)
    Gchart::Base.sparkline.should include('cht=ls')
  end

  it "should be able to generate a line xy chart" do
    Gchart::Base.line_xy.should be_an_instance_of(String)
    Gchart::Base.line_xy.should include('cht=lxy')
  end

  it "should be able to generate a scatter chart" do
    Gchart::Base.scatter.should be_an_instance_of(String)
    Gchart::Base.scatter.should include('cht=s')
  end

  it "should be able to generate a bar chart" do
    Gchart::Base.bar.should be_an_instance_of(String)
    Gchart::Base.bar.should include('cht=bvs')
  end

  it "should be able to generate a Venn diagram" do
    Gchart::Base.venn.should be_an_instance_of(String)
    Gchart::Base.venn.should include('cht=v')
  end

  it "should be able to generate a Pie Chart" do
    Gchart::Base.pie.should be_an_instance_of(String)
    Gchart::Base.pie.should include('cht=p')
  end

  it "should be able to generate a Google-O-Meter" do
    Gchart::Base.meter.should be_an_instance_of(String)
    Gchart::Base.meter.should include('cht=gom')
  end

  it "should be able to generate a map chart" do
    Gchart::Base.map.should be_an_instance_of(String)
    Gchart::Base.map.should include('cht=t')
  end

  it "should not support other types" do
    msg = "sexy is not a supported chart format. Please use one of the following: #{Gchart::Base.supported_types}."
    lambda{Gchart::Base.sexy}.should raise_error(NoMethodError)
  end
end


describe "range markers" do

  it "should be able to generate given a hash of range-marker options" do
    Gchart::Base.line(:range_markers => {:start_position => 0.59, :stop_position => 0.61, :color => 'ff0000'}).should include('chm=r,ff0000,0,0.59,0.61')
  end

  it "should be able to generate given an array of range-marker hash options" do
    Gchart::Base.line(:range_markers => [
          {:start_position => 0.59, :stop_position => 0.61, :color => 'ff0000'},
          {:start_position => 0, :stop_position => 0.6, :color => '666666'},
          {:color => 'cccccc', :start_position => 0.6, :stop_position => 1}
        ]).should include(Gchart::Base.jstize('r,ff0000,0,0.59,0.61|r,666666,0,0,0.6|r,cccccc,0,0.6,1'))
  end

  it "should allow a :overlaid? to be set" do
    Gchart::Base.line(:range_markers => {:start_position => 0.59, :stop_position => 0.61, :color => 'ffffff', :overlaid? => true}).should include('chm=r,ffffff,0,0.59,0.61,1')
    Gchart::Base.line(:range_markers => {:start_position => 0.59, :stop_position => 0.61, :color => 'ffffff', :overlaid? => false}).should include('chm=r,ffffff,0,0.59,0.61')
  end

  describe "when setting the orientation option" do
    before(:each) do
      @options = {:start_position => 0.59, :stop_position => 0.61, :color => 'ff0000'}
    end

    it "to vertical (R) if given a valid option" do
      Gchart::Base.line(:range_markers => @options.merge(:orientation => 'v')).should include('chm=R')
      Gchart::Base.line(:range_markers => @options.merge(:orientation => 'V')).should include('chm=R')
      Gchart::Base.line(:range_markers => @options.merge(:orientation => 'R')).should include('chm=R')
      Gchart::Base.line(:range_markers => @options.merge(:orientation => 'vertical')).should include('chm=R')
      Gchart::Base.line(:range_markers => @options.merge(:orientation => 'Vertical')).should include('chm=R')
    end

    it "to horizontal (r) if given a valid option (actually anything other than the vertical options)" do
      Gchart::Base.line(:range_markers => @options.merge(:orientation => 'horizontal')).should include('chm=r')
      Gchart::Base.line(:range_markers => @options.merge(:orientation => 'h')).should include('chm=r')
      Gchart::Base.line(:range_markers => @options.merge(:orientation => 'etc')).should include('chm=r')
    end

    it "if left blank defaults to horizontal (r)" do
      Gchart::Base.line(:range_markers => @options).should include('chm=r')
    end
  end
end


describe "a bar graph" do

  it "should have a default vertical orientation" do
    Gchart::Base.bar.should include('cht=bvs')
  end

  it "should be able to have a different orientation" do
    Gchart::Base.bar(:orientation => 'vertical').should include('cht=bvs')
    Gchart::Base.bar(:orientation => 'v').should include('cht=bvs')
    Gchart::Base.bar(:orientation => 'h').should include('cht=bhs')
    Gchart::Base.bar(:orientation => 'horizontal').should include('cht=bhs')
    Gchart::Base.bar(:horizontal => false).should include('cht=bvs')
  end

  it "should be set to be stacked by default" do
    Gchart::Base.bar.should include('cht=bvs')
  end

  it "should be able to stacked or grouped" do
    Gchart::Base.bar(:stacked => true).should include('cht=bvs')
    Gchart::Base.bar(:stacked => false).should include('cht=bvg')
    Gchart::Base.bar(:grouped => true).should include('cht=bvg')
    Gchart::Base.bar(:grouped => false).should include('cht=bvs')
  end

  it "should be able to have different bar colors" do
    Gchart::Base.bar(:bar_colors => 'efefef,00ffff').should include('chco=')
    Gchart::Base.bar(:bar_colors => 'efefef,00ffff').should include('chco=efefef,00ffff')
    # alias
    Gchart::Base.bar(:bar_color => 'efefef').should include('chco=efefef')
  end

  it "should be able to have different bar colors when using an array of colors" do
    Gchart::Base.bar(:bar_colors => ['efefef','00ffff']).should include('chco=efefef,00ffff')
  end

  it 'should be able to accept a string of width and spacing options' do
    Gchart::Base.bar(:bar_width_and_spacing => '25,6').should include('chbh=25,6')
  end

  it 'should be able to accept a single fixnum width and spacing option to set the bar width' do
    Gchart::Base.bar(:bar_width_and_spacing => 25).should include('chbh=25')
  end

  it 'should be able to accept an array of width and spacing options' do
    Gchart::Base.bar(:bar_width_and_spacing => [25,6,12]).should include('chbh=25,6,12')
    Gchart::Base.bar(:bar_width_and_spacing => [25,6]).should include('chbh=25,6')
    Gchart::Base.bar(:bar_width_and_spacing => [25]).should include('chbh=25')
  end

  describe "with a hash of width and spacing options" do

    before(:each) do
      @default_width         = 23
      @default_spacing       = 4
      @default_group_spacing = 8
    end

    it 'should be able to have a custom bar width' do
      Gchart::Base.bar(:bar_width_and_spacing => {:width => 19}).should include("chbh=19,#{@default_spacing},#{@default_group_spacing}")
    end

    it 'should be able to have custom spacing' do
      Gchart::Base.bar(:bar_width_and_spacing => {:spacing => 19}).should include("chbh=#{@default_width},19,#{@default_group_spacing}")
    end

    it 'should be able to have custom group spacing' do
      Gchart::Base.bar(:bar_width_and_spacing => {:group_spacing => 19}).should include("chbh=#{@default_width},#{@default_spacing},19")
    end
  end
end

describe "a line chart" do

  before(:each) do
    @title = 'Chart Title'
    @legend = ['first data set label', 'n data set label']
    @chart = Gchart::Base.line(:title => @title, :legend => @legend)
  end

  it 'should be able have a chart title' do
    @chart.should include("chtt=Chart+Title")
  end

  it "should be able to a custom color, size and alignment for title" do
     Gchart::Base.line(:title => @title, :title_color => 'FF0000').should include('chts=FF0000')
     Gchart::Base.line(:title => @title, :title_size => '20').should include('chts=454545,20')
     Gchart::Base.line(:title => @title, :title_size => '20', :title_alignment => :left).should include('chts=454545,20,l')
  end

  it "should be able to have multiple legends" do
    @chart.should include(Gchart::Base.jstize("chdl=first+data+set+label|n+data+set+label"))
  end

  it "should escape text values in url" do
    title = 'Chart & Title'
    legend = ['first data & set label', 'n data set label']
    chart = Gchart::Base.line(:title => title, :legend => legend)
    chart.should include(Gchart::Base.jstize("chdl=first+data+%26+set+label|n+data+set+label"))
  end

  it "should be able to have one legend" do
    chart = Gchart::Base.line(:legend => 'legend label')
    chart.should include("chdl=legend+label")
  end

  it "should be able to set the position of the legend" do
    title = 'Chart & Title'
    legend = ['first data & set label', 'n data set label']

    chart = Gchart::Base.line(:title => title, :legend => legend, :legend_position => :bottom_vertical)
    chart.should include("chdlp=bv")

    chart = Gchart::Base.line(:title => title, :legend => legend, :legend_position => 'r')
    chart.should include("chdlp=r")
  end

  it "should be able to set the background fill" do
    Gchart::Base.line(:bg => 'efefef').should include("chf=bg,s,efefef")
    Gchart::Base.line(:bg => {:color => 'efefef', :type => 'solid'}).should include("chf=bg,s,efefef")

    Gchart::Base.line(:bg => {:color => 'efefef', :type => 'gradient'}).should include("chf=bg,lg,0,efefef,0,ffffff,1")
    Gchart::Base.line(:bg => {:color => 'efefef,0,ffffff,1', :type => 'gradient'}).should include("chf=bg,lg,0,efefef,0,ffffff,1")
    Gchart::Base.line(:bg => {:color => 'efefef', :type => 'gradient', :angle => 90}).should include("chf=bg,lg,90,efefef,0,ffffff,1")

    Gchart::Base.line(:bg => {:color => 'efefef', :type => 'stripes'}).should include("chf=bg,ls,90,efefef,0.2,ffffff,0.2")
  end

  it "should be able to set a graph fill" do
    Gchart::Base.line(:graph_bg => 'efefef').should include("chf=c,s,efefef")
    Gchart::Base.line(:graph_bg => {:color => 'efefef', :type => 'solid'}).should include("chf=c,s,efefef")
    Gchart::Base.line(:graph_bg => {:color => 'efefef', :type => 'gradient'}).should include("chf=c,lg,0,efefef,0,ffffff,1")
    Gchart::Base.line(:graph_bg => {:color => 'efefef,0,ffffff,1', :type => 'gradient'}).should include("chf=c,lg,0,efefef,0,ffffff,1")
    Gchart::Base.line(:graph_bg => {:color => 'efefef', :type => 'gradient', :angle => 90}).should include("chf=c,lg,90,efefef,0,ffffff,1")
  end

  it "should be able to set both a graph and a background fill" do
    Gchart::Base.line(:bg => 'efefef', :graph_bg => '76A4FB').should match /chf=(bg,s,efefef\|c,s,76A4FB|c,s,76A4FB\|bg,s,efefef)/
  end

  it "should be able to have different line colors" do
    Gchart::Base.line(:line_colors => 'efefef|00ffff').should include(Gchart::Base.jstize('chco=efefef|00ffff'))
    Gchart::Base.line(:line_color => 'efefef|00ffff').should include(Gchart::Base.jstize('chco=efefef|00ffff'))
  end

  it "should be able to render a graph where all the data values are 0" do
    Gchart::Base.line(:data => [0, 0, 0]).should include("chd=s:AAA")
  end
end

describe "a sparkline chart" do

  before(:each) do
    @title = 'Chart Title'
    @legend = ['first data set label', 'n data set label']
    @jstized_legend = Gchart::Base.jstize(@legend.join('|'))
    @data = [27,25,25,25,25,27,100,31,25,36,25,25,39,25,31,25,25,25,26,26,25,25,28,25,25,100,28,27,31,25,27,27,29,25,27,26,26,25,26,26,35,33,34,25,26,25,36,25,26,37,33,33,37,37,39,25,25,25,25]
    @chart = Gchart::Base.sparkline(:title => @title, :data => @data, :legend => @legend)
  end

  it "should create a sparkline" do
    @chart.should include('cht=ls')
  end

  it 'should be able have a chart title' do
    @chart.should include("chtt=Chart+Title")
  end

  it "should be able to a custom color and size title" do
     Gchart::Base.sparkline(:title => @title, :title_color => 'FF0000').should include('chts=FF0000')
     Gchart::Base.sparkline(:title => @title, :title_size => '20').should include('chts=454545,20')
  end

  it "should be able to have multiple legends" do
    @chart.should include(Gchart::Base.jstize("chdl=first+data+set+label|n+data+set+label"))
  end

  it "should be able to have one legend" do
    chart = Gchart::Base.sparkline(:legend => 'legend label')
    chart.should include("chdl=legend+label")
  end

  it "should be able to set the background fill" do
    Gchart::Base.sparkline(:bg => 'efefef').should include("chf=bg,s,efefef")
    Gchart::Base.sparkline(:bg => {:color => 'efefef', :type => 'solid'}).should include("chf=bg,s,efefef")

    Gchart::Base.sparkline(:bg => {:color => 'efefef', :type => 'gradient'}).should include("chf=bg,lg,0,efefef,0,ffffff,1")
    Gchart::Base.sparkline(:bg => {:color => 'efefef,0,ffffff,1', :type => 'gradient'}).should include("chf=bg,lg,0,efefef,0,ffffff,1")
    Gchart::Base.sparkline(:bg => {:color => 'efefef', :type => 'gradient', :angle => 90}).should include("chf=bg,lg,90,efefef,0,ffffff,1")

    Gchart::Base.sparkline(:bg => {:color => 'efefef', :type => 'stripes'}).should include("chf=bg,ls,90,efefef,0.2,ffffff,0.2")
  end

  it "should be able to set a graph fill" do
    Gchart::Base.sparkline(:graph_bg => 'efefef').should include("chf=c,s,efefef")
    Gchart::Base.sparkline(:graph_bg => {:color => 'efefef', :type => 'solid'}).should include("chf=c,s,efefef")
    Gchart::Base.sparkline(:graph_bg => {:color => 'efefef', :type => 'gradient'}).should include("chf=c,lg,0,efefef,0,ffffff,1")
    Gchart::Base.sparkline(:graph_bg => {:color => 'efefef,0,ffffff,1', :type => 'gradient'}).should include("chf=c,lg,0,efefef,0,ffffff,1")
    Gchart::Base.sparkline(:graph_bg => {:color => 'efefef', :type => 'gradient', :angle => 90}).should include("chf=c,lg,90,efefef,0,ffffff,1")
  end

  it "should be able to set both a graph and a background fill" do
    Gchart::Base.sparkline(:bg => 'efefef', :graph_bg => '76A4FB').should match(/chf=(bg,s,efefef\|c,s,76A4FB|c,s,76A4FB\|bg,s,efefef)/)
  end

  it "should be able to have different line colors" do
    Gchart::Base.sparkline(:line_colors => 'efefef|00ffff').should include(Gchart::Base.jstize('chco=efefef|00ffff'))
    Gchart::Base.sparkline(:line_color => 'efefef|00ffff').should include(Gchart::Base.jstize('chco=efefef|00ffff'))
  end
end

describe "a 3d pie chart" do

  before(:each) do
    @title = 'Chart Title'
    @legend = ['first data set label', 'n data set label']
    @jstized_legend = Gchart::Base.jstize(@legend.join('|'))
    @data = [12,8,40,15,5]
    @chart = Gchart::Base.pie(:title => @title, :legend => @legend, :data => @data)
  end

  it "should create a pie" do
    @chart.should include('cht=p')
  end

  it "should be able to be in 3d" do
    Gchart::Base.pie_3d(:title => @title, :legend => @legend, :data => @data).should include('cht=p3')
  end
end

describe "a google-o-meter" do

  before(:each) do
    @data = [70]
    @legend = ['arrow points here']
    @jstized_legend = Gchart::Base.jstize(@legend.join('|'))
    @chart = Gchart::Base.meter(:data => @data)
  end

  it "should create a meter" do
    @chart.should include('cht=gom')
  end

  it "should be able to set a solid background fill" do
    Gchart::Base.meter(:bg => 'efefef').should include("chf=bg,s,efefef")
    Gchart::Base.meter(:bg => {:color => 'efefef', :type => 'solid'}).should include("chf=bg,s,efefef")
  end

  it "should be able to set labels by using the legend or labesl accessor" do
    Gchart::Base.meter(:title => @title, :labels => @legend, :data => @data).should include("chl=#{@jstized_legend}")
    Gchart::Base.meter(:title => @title, :labels => @legend, :data => @data).should == Gchart::Base.meter(:title => @title, :legend => @legend, :data => @data)
  end
end

describe "a map chart" do

  before(:each) do
    @data = [0,100,50,32]
    @geographical_area = 'usa'
    @map_colors = ['FFFFFF', 'FF0000', 'FFFF00', '00FF00']
    @country_codes = ['MT', 'WY', "ID", 'SD']
    @chart = Gchart::Base.map(:data => @data, :encoding => 'text', :size => '400x300',
      :geographical_area => @geographical_area, :map_colors => @map_colors,
      :country_codes => @country_codes)
  end

  it "should create a map" do
    @chart.should include('cht=t')
  end

  it "should set the geographical area" do
    @chart.should include('chtm=usa')
  end

  it "should set the map colors" do
    @chart.should include('chco=FFFFFF,FF0000,FFFF00,00FF00')
  end

  it "should set the country/state codes" do
    @chart.should include('chld=MTWYIDSD')
  end

  it "should set the chart data" do
    @chart.should include('chd=t:0,100,50,32')
  end
end

describe 'exporting a chart' do

  it "should be available in the url format by default" do
    Gchart::Base.line(:data => [0, 26], :format => 'url').should == Gchart::Base.line(:data => [0, 26])
  end

  it "should be available as an image tag" do
    Gchart::Base.line(:data => [0, 26], :format => 'image_tag').should match(/<img src=(.*) width="300" height="200" alt="Google Chart" \/>/)
  end

  it "should be available as an image tag using img_tag alias" do
    Gchart::Base.line(:data => [0, 26], :format => 'img_tag').should match(/<img src=(.*) width="300" height="200" alt="Google Chart" \/>/)
  end

  it "should be available as an image tag using custom dimensions" do
    Gchart::Base.line(:data => [0, 26], :format => 'image_tag', :size => '400x400').should match(/<img src=(.*) width="400" height="400" alt="Google Chart" \/>/)
  end

  it "should be available as an image tag using custom alt text" do
    Gchart::Base.line(:data => [0, 26], :format => 'image_tag', :alt => 'Sexy chart').should match(/<img src=(.*) width="300" height="200" alt="Sexy chart" \/>/)
  end

  it "should be available as an image tag using custom title text" do
    Gchart::Base.line(:data => [0, 26], :format => 'image_tag', :title => 'Sexy chart').should match(/<img src=(.*) width="300" height="200" alt="Google Chart" title="Sexy chart" \/>/)
  end

  it "should be available as an image tag using custom css id selector" do
    Gchart::Base.line(:data => [0, 26], :format => 'image_tag', :id => 'chart').should match(/<img id="chart" src=(.*) width="300" height="200" alt="Google Chart" \/>/)
  end

  it "should be available as an image tag using custom css class selector" do
    Gchart::Base.line(:data => [0, 26], :format => 'image_tag', :class => 'chart').should match(/<img class="chart" src=(.*) width="300" height="200" alt="Google Chart" \/>/)
  end

  it "should use ampersands to separate key/value pairs in URLs by default" do
    Gchart::Base.line(:data => [0, 26]).should include "&"
    Gchart::Base.line(:data => [0, 26]).should_not include "&amp;"
  end

  it "should escape ampersands in URLs when used as an image tag" do
    Gchart::Base.line(:data => [0, 26], :format => 'image_tag', :class => 'chart').should satisfy {|chart| chart.should include "&amp;" }
  end

  it "should be available as a file" do
    File.delete('chart.png') if File.exist?('chart.png')
    Gchart::Base.line(:data => [0, 26], :format => 'file')
    File.exist?('chart.png').should be_true
    File.delete('chart.png') if File.exist?('chart.png')
  end

  it "should be available as a file using a custom file name" do
    File.delete('custom_file_name.png') if File.exist?('custom_file_name.png')
    Gchart::Base.line(:data => [0, 26], :format => 'file', :filename => 'custom_file_name.png')
    File.exist?('custom_file_name.png').should be_true
    File.delete('custom_file_name.png') if File.exist?('custom_file_name.png')
  end

  it "should work even with multiple attrs" do
    File.delete('foo.png') if File.exist?('foo.png')
    Gchart::Base.line(:size => '400x200',
                :data => [1,2,3,4,5],
                # :axis_labels => [[1,2,3,4, 5], %w[foo bar]],
                :axis_with_labels => 'x,r',
                :format => "file",
                :filename => "foo.png"
                )
    File.exist?('foo.png').should be_true
    File.delete('foo.png') if File.exist?('foo.png')
  end
end

describe 'SSL support' do
  it 'should change url if is presented' do
    Gchart::Base.line(:use_ssl => true).should include('https://chart.googleapis.com/chart?')
  end

  it "should be available as a file" do
    File.delete('chart.png') if File.exist?('chart.png')
    Gchart::Base.line(:data => [0, 26], :format => 'file', :use_ssl => true)
    File.exist?('chart.png').should be_true
    File.delete('chart.png') if File.exist?('chart.png')
  end
end

