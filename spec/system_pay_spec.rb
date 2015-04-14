require 'spec_helper'

describe SystemPay do

  context "configuration" do
    before(:each) do
      SystemPay::Vads.vads_site_id = nil
      SystemPay::Vads.certificat = nil
      SystemPay::Vads.vads_ctx_mode = nil
      SystemPay::Vads.vads_contrib = nil
    end

    it "should allow setting of the vads_site_id" do
      SystemPay::Vads.vads_site_id = '228159'
      SystemPay::Vads.vads_site_id.should == '228159'
    end

    it "should allow setting of the certificate" do
      SystemPay::Vads.certificat = '1234194862125022'
      SystemPay::Vads.certificat.should == '1234194862125022'
    end

    it "should allow setting of the production mode" do
      SystemPay::Vads.vads_ctx_mode = 'PRODUCTION'
      SystemPay::Vads.vads_ctx_mode.should == 'PRODUCTION'
    end

    it "should allow setting of the contribution name" do
      SystemPay::Vads.vads_contrib = 'Rspec'
      SystemPay::Vads.vads_contrib.should == 'Rspec'
    end


  end

  before(:all) do
    SystemPay::Vads.vads_site_id = '654321'
    SystemPay::Vads.certificat = '8877665544332211'
  end

  describe '.new' do


    context "payment transaction" do
      it 'should raise an error if the amount parameter is not set' do
        lambda do
          system_pay = SystemPay::Vads.new(:trans_id => 1)
        end.should raise_error(ArgumentError)
      end

      it 'should raise an error if the trans_id parameter is not set' do
        lambda do
          system_pay = SystemPay::Vads.new(:amount => 100)
        end.should raise_error(ArgumentError)
      end

      it 'should pass with trans_id and amount parameters passed' do
        lambda do
          system_pay = SystemPay::Vads.new(:amount => 100, :trans_id => 2)
        end.should_not raise_error
      end

      it 'should pad trans_id' do
        system_pay = SystemPay::Vads.new(:amount => 100, :trans_id => 2)
        system_pay.vads_trans_id.should == "000002"
      end

      it 'should not pad trans_id with 6 digits' do
        system_pay = SystemPay::Vads.new(:amount => 100, :trans_id => 999999)
        system_pay.vads_trans_id.should == "999999"
      end

      it "should include currency" do
        SystemPay::Vads.new(:amount => 100, :trans_id => 999999).vads_currency.should == "978"
      end

      it "should include vads_page_action" do
        SystemPay::Vads.new(:amount => 100, :trans_id => 999999).vads_page_action.should == "PAYMENT"
      end

      it "should include vads_payment_config" do
        SystemPay::Vads.new(:amount => 100, :trans_id => 999999).vads_payment_config.should == "SINGLE"
      end

      it "should include vads_trans_date" do
        SystemPay::Vads.new(:amount => 100, :trans_id => 999999).vads_trans_date.should_not be_nil
      end
    end

    context "non payment transaction" do
      it "allows empty amount" do
        lambda do
          SystemPay::Vads.new(:vads_identifier => "20140323iRctSr", :vads_page_action => "REGISTER_UPDATE")
        end.should_not raise_error
      end

      it "allows empty trans_id" do
        lambda do
          SystemPay::Vads.new(:vads_identifier => "20140323iRctSr", :vads_page_action => "REGISTER_UPDATE")
        end.should_not raise_error
      end

      it 'raises an error if the vads_identifier parameter is not set' do
        lambda do
          SystemPay::Vads.new(:vads_page_action => "REGISTER_UPDATE")
        end.should raise_error(ArgumentError)
      end

      it "allows setting vads_page_action" do
        system_pay = SystemPay::Vads.new(:vads_identifier => "20140323iRctSr", :vads_page_action => "REGISTER_UPDATE")
        system_pay.vads_page_action.should == "REGISTER_UPDATE"
      end

      it "should not include currency" do
        SystemPay::Vads.new(:vads_identifier => "20140323iRctSr", :vads_page_action => "REGISTER_UPDATE").vads_currency.should be_nil
      end

      it "should not include vads_payment_config" do
        SystemPay::Vads.new(:vads_identifier => "20140323iRctSr", :vads_page_action => "REGISTER_UPDATE").vads_payment_config.should be_nil
      end

      it "should not include vads_trans_date" do
        SystemPay::Vads.new(:vads_identifier => "20140323iRctSr", :vads_page_action => "REGISTER_UPDATE").vads_trans_date.should_not be_nil
      end
    end

  end

  describe '#signature' do

    it 'should return a correct signature' do
      system_pay = SystemPay::Vads.new(:amount => 100, :trans_id => 2, :trans_date => "20120420121326")
      system_pay.signature.should == 'f5bec689b57ebefa81c84d184f4bca05e7e8e106'
    end

  end

  describe '#params' do

    it 'should return the params to pass to the bank' do
      system_pay = SystemPay::Vads.new(:amount => 100, :trans_id => 2, :trans_date => "20120420121326")
      params = {"vads_payment_config"=>"SINGLE", "vads_ctx_mode"=>nil, "vads_contrib"=>"Rspec", "vads_action_mode"=>"INTERACTIVE", "vads_page_action"=>"PAYMENT", "vads_validation_mode"=>"1", "vads_shop_url"=>"", "vads_trans_id"=>"000002", "vads_site_id"=>nil, "signature"=>"f5bec689b57ebefa81c84d184f4bca05e7e8e106", "vads_return_mode"=>"POST", "vads_currency"=>"978", "vads_shop_name"=>"", "vads_amount"=>100, "vads_version"=>"V2", "vads_trans_date"=>"20120420121326"}

      system_pay.params.should == params
    end

  end

  describe '.valid_signature?' do

    it 'should return true when valid params are entered' do
      params = {"vads_payment_config"=>"SINGLE", "vads_ctx_mode"=>nil, "vads_contrib"=>"Rspec", "vads_action_mode"=>"INTERACTIVE", "vads_page_action"=>"PAYMENT", "vads_validation_mode"=>"1", "vads_shop_url"=>"", "vads_trans_id"=>"000002", "vads_site_id"=>nil, "signature"=>"f5bec689b57ebefa81c84d184f4bca05e7e8e106", "vads_return_mode"=>"POST", "vads_currency"=>"978", "vads_shop_name"=>"", "vads_amount"=>100, "vads_version"=>"V2", "vads_trans_date"=>"20120420121326"}

      SystemPay::Vads.valid_signature?(params).should be_truthy
    end

    it 'should return false when invalid params are entered' do
      params = {"vads_payment_config"=>"SINGLE", "vads_ctx_mode"=>nil, "vads_contrib"=>"Rspec", "vads_action_mode"=>"INTERACTIVE", "vads_page_action"=>"PAYMENT", "vads_validation_mode"=>"1", "vads_shop_url"=>"", "vads_trans_id"=>"000002", "vads_site_id"=>nil, "signature"=>"f6bec689b57ebefa81c84d184f4bca05e7e8e106", "vads_return_mode"=>"POST", "vads_currency"=>"978", "vads_shop_name"=>"", "vads_amount"=>100, "vads_version"=>"V2", "vads_trans_date"=>"20120420121326"}

      SystemPay::Vads.valid_signature?(params).should be_falsy
    end

  end


end
