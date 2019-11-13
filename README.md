# Counseling Book Tags 2

## Overview
In 2018 the first version of Counseling Book Tags was released for public use, allowing professionals to tag books with meaningful identifiers and better share resources among their colleagues. This repo houses the second version of the Counseling Book Tags app which now takes advantage of the development speed and maintainability enabled by Ruby on Rails 6 and the Stimulus.js javascript framework. Other notable improvements include:
* Improved user authentication and security
* Modernized UI for easy use on desktop and mobile
* Caching to speed up data from external API's
* More powerful book and tag searching functionality

Create a free account and try out the live site today at https://www.counselingbooktags.com

## Lessons Learned
I really enjoyed building a new app in a familiar domain using Ruby on Rails 6 and Stimulus.js. Both of these technologies helped me move quickly and achieve usable results that were easy to troubleshoot and improve throughout the development process.

### Working With Data
ActiveRecord provides plenty of easy and advanced tools for writing database queries and working with data. In this project I worked with Postgres arrays in more depth than I had in the past. This data structure allowed me to normalize my data while improving the speed of my searching queries, whether by book title or author name keywords, or by tags shared across books. Though it's a small thing, I found Rails' default logging in development incredibly helpful during this process. I was able to see every SQL query used as I iterated towards more efficient data access calls which enabled me to make smarter decisions earlier in the development process.

### JavaScript
I have worked on several projects now where I created interactive, modern-feeling UI's without using a JavaScript framework. The upside of this approach is that I can include only the resources I need, speeding up page load times and performance. Unfortunately, the downside of large amounts of "vanilla" JavaScript is that it can get unruly and hard to maintain more quickly unless one implements a self-enforced file structuring paradigm. Stimulus.js feels like it works hard to meet me in the middle, providing much of the code readability and organization benefits that a full-sized framework would without requiring the huge overhead when all I need is a little interactivity on a page.

Luckily, Rails also includes [webpacker](https://github.com/rails/webpacker), which took care of my asset compilation right out of the box, no extra hassle required on my end. In general I am not a huge fan of JavaScript build tools and the additional complexity they add to a project, but even with webpacker and Stimulus, I still have nowhere near the build pipeline to maintain as I would using a bigger JS framework.

### Bonus: CSS
I'd like to also give a +1 to the [Bulma](https://bulma.io/) CSS framework that I used to put this app together. It ships with _zero_ JavaScript and included all the components I needed to get up and running quickly. I chose to download the source code and compile my own version of the framework during development in order to pick and choose which components I included. This helped me minimize the footprint of the framework even further, while not limiting my creativity.

## Developing locally
Running in local development:
`rails db:create db:migrate`
`. ./tmp/.env && rails server`

To run the test suite:
`. ./tmp/.env && rails test`
