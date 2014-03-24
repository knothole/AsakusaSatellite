# -*- encoding: utf-8 -*-
module Api
  module V1
    class UserController < ApplicationController
      include ApiHelper

      before_filter :check_spell

      def show
        user = current_user
        if user
          render :json => user.to_json
          return
        end
        render_error 'user not found', 403
      end

      def add_device
        manage_device do |user|
          if user.devices.where(:name => params[:device]).empty?
            user.devices << Device.new(:name => params[:device],
                                       :device_name => params[:name],
                                       :device_type => params[:type] || 'iphone')
          end

          unless user.save
            render_error 'cannot save device data'
            return
          end

          render :json => user.to_json
        end
      end

      def delete_device
        manage_device do |user|
          unless user.devices.where(:name => params[:device]).empty?
            device = user.devices.where(:name => params[:device])
            device.destroy
          end

          render :json => user.to_json
        end
      end

      private
      def manage_device(&proc)
        user = current_user
        unless user
          render_error 'user not found', 403
          return
        end

        user.devices ||= []
        proc.call user
      end

    end
  end
end
