module.exports = function(grunt) {

	grunt.initConfig({
		coffee: {
			app: {
				expand: true,
				cwd: './src',
				src: ['**/*.coffee'],
				dest: './lib',
				ext: '.js'
			},
		},
		watch: {
			app: {
				files: 'src/**/*.coffee',
				tasks: ['clean','coffee']
			},
			test: {
				files: 'src/**/*.coffee',
				tasks: ['clean', 'coffee', 'test']
			}
		},
		simplemocha: {
			dev: {
				src: './lib/tests/**/**/*.js',
				options: {
					slow: 200,
			        timeout: 5000,
			        ignoreLeaks: false,
			        reporter: 'spec'
			    }
			}
		},
		clean: {
			build: {
		    	src: ["./lib/tests", "./lib/api", "./lib/evented.io", "./lib/middleware"]
		    }
		}
	});

	grunt.loadNpmTasks('grunt-contrib-coffee');
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.loadNpmTasks('grunt-simple-mocha');
	grunt.loadNpmTasks('grunt-contrib-clean');

	grunt.registerTask('default', ['clean', 'coffee', 'watch:app']);
	grunt.registerTask('test', ['clean', 'coffee','simplemocha:dev']);
	grunt.registerTask('dev', ['clean', 'coffee', 'simplemocha:dev', 'watch:test']);


};
