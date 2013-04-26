class NameIsGeneExpDiffValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    return if not value.kind_of? ActionDispatch::Http::UploadedFile
    if (value.original_filename != 'gene_exp.diff')
      record.errors[attribute] << "must be the gene_exp.diff file."
    end
  end
end
