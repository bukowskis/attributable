require "spec_helper"

describe "Attribrutal#attributes" do

  let (:bar) { Bar.new foo: nil, bar: 10, baz: { alpha: 10, beta: "20" } }
  let (:bar_with_defaults) { Bar.new }

  it "records defined attributes" do
    Bar.attributes.keys.should == [:foo, :bar, :baz]
  end

  it "records defined attribute types" do
    Bar.attributes.values.should == [Coercer::Boolean, Coercer::String, Coercer::Baz]
  end

  it "supports mass assignment" do
    bar.raw_attributes.values.should == [nil, 10, { alpha: 10, beta: "20" }]
    bar.attributes[:foo].should == false
    bar.attributes[:bar].should == "10"
    bar.attributes[:baz].alpha.should == 10
    bar.attributes[:baz].beta.should == 20
  end

  it "performs coercion" do
    attributes = bar.attributes
    attributes[:foo].should == false
    attributes[:bar].should == "10"
  end

  it "supports recursive coercion" do
    attributes = bar.attributes
    attributes[:baz].alpha.should == 10
    attributes[:baz].beta.should == 20
  end

  it "supports defaults" do
    bar_with_defaults.bar.should == "bar"
    bar_with_defaults.baz.class.should == Baz
    bar_with_defaults.baz.alpha.should == 50
    bar_with_defaults.baz.beta.should == 100
  end

  it "is fast enough" do
    initialization_time = 1000 * Benchmark.realtime do
      10_000.times { Bar.new }
    end
    initialization_time.should < 5

    coercion_time = 1000 * Benchmark.realtime do
      10_000.times { Bar.new foo: nil, bar: 10, baz: { alpha: "1", beta: "2" } }
    end
    coercion_time.should < 50
  end

end