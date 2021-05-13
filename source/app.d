import std.stdio;
import std.format;
import std.conv;
import requests;
import commandr;
import asdf;
import models;
import clients.sourceclient;
import clients.opmlclient;
import clients.feedsclient;
import commandcontroller;

void main(string[] args)
{
	auto url = "http://localhost:8000";
	auto sourceClient = new SourceClient(url);
	auto feedsClient = new FeedsClient(url);
	auto opmlClient = new OpmlClient(url);
	auto c = new CommandController(
		sourceClient,
		opmlClient,
		feedsClient
	);

	auto result = new Program("truerss-cli", "1.0.0")
		.summary("Command Line Interface for TrueRSS reader")
		.add(
			new Command("all").summary("Display all sources")
		)
		.add(
			new Command("view").summary("Display source overview")
			  .add(new Argument("id", "Source id"))
		)
		.add(
			new Command("opml").summary("Download generated OPML")
		)
	    .add(
			new Command("latest").summary("Display latest entries")
		)
	    .add(
			new Command("favorites").summary("Display favorites entries")
		)
	    .add(
			new Command("add").summary("Add new source")
				.add(new Argument("url", "URL"))
				.add(new Argument("name", "Name").optional)
				.add(new Argument("interval", "Interval").optional)
		)
		.parse(args);

	result
		.on("all", (ignored) {
			c.all();
		})
		.on("view", (args) {
			c.overview(args.arg("id"));
		})
		.on("opml", (ignored) {
			c.download();
		})
		.on("latest", (ignored) {
			c.latest();
		})
		.on("favorites", (ignored) {
			c.favorites();
		})
		.on("add", (args) {
			c.add(args.arg("url"), args.arg("name"), args.arg("interval"));
		});

}
