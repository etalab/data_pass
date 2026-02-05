# frozen_string_literal: true

module Organisms
  module AuthorizationRequestForms
    class LegalFrameworkComponent < ApplicationComponent
      attr_reader :form, :field_prefix

      def initialize(form:, field_prefix:)
        @form = form
        @field_prefix = field_prefix
      end

      def render?
        form.object.present?
      end

      private

      def description
        @description ||= wording_for('description')
      end

      def document_hint
        wording_for('justificatif.document_hint')
      end

      def document_label
        wording_for('justificatif.document_label')
      end

      def legal_justificatif(key)
        form.wording_for("legal.justificatif.#{key}")
      rescue I18n::MissingTranslationData
        nil
      end

      def separator_text
        wording_for('justificatif.separator') || 'OU'
      end

      def show_header?
        title.present?
      end

      def supporting_documents_description
        @supporting_documents_description ||= wording_for('justificatif.description') || legal_justificatif('description')
      end

      def supporting_documents_title
        @supporting_documents_title ||= wording_for('justificatif.title') || legal_justificatif('title')
      end

      def title
        @title ||= wording_for('title')
      end

      def url_label
        wording_for('justificatif.url_label')
      end

      def wording_for(key)
        form.wording_for("#{field_prefix}.#{key}")
      rescue I18n::MissingTranslationData
        nil
      end
    end
  end
end
