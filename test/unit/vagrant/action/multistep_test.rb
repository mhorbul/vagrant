require File.expand_path("../../../base", __FILE__)

describe Vagrant::Action::MultiStep do
  it "should compose a series of steps" do
    step_A = Class.new(Vagrant::Action::Step) do
      input  :obj
      output :obj

      def execute
        @obj << "A"
        return :obj => @obj
      end
    end

    step_B = Class.new(Vagrant::Action::Step) do
      input  :obj
      output :result

      def execute
        return :result => (@obj << "B")
      end
    end

    obj = []

    ms = described_class.new
    ms.step step_A
    ms.step step_B
    ms.call(:obj => obj).should == { :result => ["A", "B"] }
  end

  it "should allow for custom inputs to pass to specific steps" do
    step_A = Class.new(Vagrant::Action::Step) do
      def execute
        # Do nothing.
      end
    end

    step_B = Class.new(Vagrant::Action::Step) do
      input :obj

      def execute
        @obj << "B"
      end
    end

    obj = []

    ms = described_class.new
    ms.step step_A
    ms.step step_B, :obj
    ms.call(:obj => obj)

    obj.should == ["B"]
  end

  it "should be able to remap input names" do
    step_A = Class.new(Vagrant::Action::Step) do
      output :foo

      def execute
        return :foo => "A"
      end
    end

    step_B = Class.new(Vagrant::Action::Step) do
      input  :from
      output :value

      def execute
        return :value => @from
      end
    end

    obj = []

    ms = described_class.new
    ms.step step_A
    ms.step step_B, :map => { :foo => :from }
    ms.call.should == { :value => "A" }
  end
end