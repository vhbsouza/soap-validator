# frozen_string_literal: true

class WsdlValidator
  attr_accessor :show_schemas
  attr_accessor :schemas
  attr_accessor :doc

  # Parse WSDL storing authentication and all schemas from it
  # @param [String] wsdl_url URL to where WSDL is stored or location to where file is stored
  def initialize(wsdl_url)
    self.doc = Wasabi.document wsdl_url
    self.show_schemas = parse_wsdl_schemas
    self.schemas = Nokogiri::XML::Schema(show_schemas.join)
  rescue Nokogiri::XML::SyntaxError => e
    puts "Error for #{show_schemas}"
    raise e
  end
  
  # Gets the namespaces from the SOAP Envelope & Body element, adds them to the root element underneath the body
  # and returns that element.
  # @note This is not the ideal approach. Ideally Nokogiri parser would be able to understand SOAP xsd as well
  # @return [Nokogiri::XML::Document] Retrieve root element from SOAP
  def extract_root_from_soap(envelope)
    body = envelope.children.find { |child| child.name == 'Body' }
    root_element = body.children.reject { |child| child.is_a?(Nokogiri::XML::Text) }.first
    envelope.namespaces.each { |namespace, value| root_element[namespace] = value }
    body.namespaces.each { |namespace, value| root_element[namespace] = value }
    Nokogiri::XML root_element.to_s # Convert to Xml Document
  end

  # Returns a list of syntax errors. Empty list indicates valid xml
  # @param [String, Nokogiri::XML::NodeSet] xml
  # @return [Array] List of Nokogiri::XML::SyntaxError objects
  def errors_for(xml)
    raise "Incorrect type #{xml.class}" unless [String, Nokogiri::XML::Document, Nokogiri::XML::NodeSet].include? xml.class

    xml_under_test = Nokogiri::XML(xml.to_s)
    soap_envelope = xml_under_test.children.find { |e| e.name == 'Envelope' }
    xml_under_test = extract_root_from_soap(soap_envelope) if soap_envelope
    schemas.validate(xml_under_test)
  end

  alias validate errors_for

  # @return [Hash] All namespaces defined throughout Wsdl
  def namespaces
    doc.parser.document.collect_namespaces
  end

  private

  # Join all the schemas within the WSDL, importing schemas if necessary
  # @return [String] Schema XML contained within WSDL
  def parse_wsdl_schemas
    doc.parser.schemas.collect do |schema|
      add_global_namespace_to schema
    end
  end

  # Add namespaces from wsdl document to each schema
  # Sometimes schemas are defined there and referenced within the types
  # @return [String] String representing XML with global schemas added
  def add_global_namespace_to(schema)
    namespaces.each { |namespace, value| schema[namespace] = value }
    schema.to_s
  end
end
