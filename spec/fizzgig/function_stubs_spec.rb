require_relative '../spec_helper'
require 'fizzgig/function_stubs'

describe Fizzgig::FunctionStubs do
  describe '.has_stub?' do
    subject { LSpace.with(:function_stubs => stubs) { Fizzgig::FunctionStubs.has_stub?(fname, args) } }

    context 'single arg fn' do
      let(:stubs) { { :myfn => {['foo'] => 'bar'}} }
      let(:fname) {:myfn}
      let(:args)  {['foo']}
      it {should be_true}
    end

    context 'multi arg fn' do
      let(:stubs) { { :myfn => {['foo','bar'] => 'giraffe'}} }
      let(:fname) {:myfn}
      let(:args)  {['foo','bar']}
      it {should be_true}
    end
  end

  describe '.get_stub' do
    subject { LSpace.with(:function_stubs => stubs) { Fizzgig::FunctionStubs.get_stub(fname, args) } }
    context 'single arg fn' do
      let(:stubs) { { :myfn => {['foo'] => 'bar'}} }
      let(:fname) {:myfn}
      let(:args)  {['foo']}
      it {should == 'bar'}
    end

    context 'multi arg fn' do
      let(:stubs) { { :myfn => {['foo','bar'] => 'giraffe'}} }
      let(:fname) {:myfn}
      let(:args)  {['foo','bar']}
      it {should == 'giraffe'}
    end
  end
end
