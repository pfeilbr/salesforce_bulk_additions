## salesforce-bulk-additions

Additional functionality added to the [salesforce_bulk](https://github.com/jorgevaldivia/salesforce_bulk) gem

### Additional Methods

Bulk query output streamed to file.  The ```query``` method of salesforce_bulk stores the output in memory, which is an issue for large result sets.

```query_to_file(object_name, soql, output_file_path)```

### Running Examples

Create ```.env``` file in root and populate following values

	USERNAME=first.last@example.com
	PASSWORD=secret
	SANDBOX=true

Install dependencies

	bundle install

Run examples

	bundle exec ruby example.rb