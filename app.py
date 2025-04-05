    import os
    import subprocess
    from flask import Flask, request, jsonify

    app = Flask(__name__)

    # Define the path to the fabric binary within the container
    FABRIC_BINARY = "/usr/local/bin/fabric"

    @app.route('/execute_pattern', methods=['POST'])
    def execute_pattern():
        """
        Executes a Fabric pattern based on JSON input.
        Expects JSON like: {"pattern": "pattern_name", "data": "input_data"}
        """
        if not request.is_json:
            return jsonify({"error": "Request must be JSON"}), 400

        data = request.get_json()
        pattern = data.get('pattern')
        input_data = data.get('data')

        if not pattern:
            return jsonify({"error": "Missing 'pattern' in JSON body"}), 400
        if not input_data:
            return jsonify({"error": "Missing 'data' in JSON body"}), 400

        # Construct the command
        # IMPORTANT: We run fabric directly, not the fabric-n8n wrapper here.
        # Subprocess handles non-interactive execution better.
        command = [FABRIC_BINARY, "--pattern", pattern, "--data", input_data]

        try:
            # Add API keys from environment variables if they exist
            # Fabric often reads these directly, but explicit passing can sometimes help
            env = os.environ.copy()

            print(f"Executing command: {' '.join(command)}") # Log the command being run
            print(f"Using environment keys: {list(env.keys())}") # Log available env keys

            process = subprocess.run(
                command,
                capture_output=True,
                text=True,
                check=True,  # Raise an exception if the command fails
                env=env,
                timeout=300 # Add a timeout (e.g., 5 minutes)
            )

            print(f"Fabric stdout:\n{process.stdout}")
            print(f"Fabric stderr:\n{process.stderr}") # Stderr might contain useful info even on success

            # Return the standard output from Fabric
            return jsonify({"result": process.stdout.strip()})

        except subprocess.CalledProcessError as e:
            print(f"Error executing Fabric: {e}")
            print(f"Stderr: {e.stderr}")
            return jsonify({
                "error": "Fabric command failed",
                "stderr": e.stderr.strip(),
                "stdout": e.stdout.strip() # Include stdout too, might have partial output
                }), 500
        except subprocess.TimeoutExpired as e:
            print(f"Error: Fabric command timed out")
            print(f"Stderr: {e.stderr.decode(errors='ignore') if e.stderr else 'N/A'}")
            print(f"Stdout: {e.stdout.decode(errors='ignore') if e.stdout else 'N/A'}")
            return jsonify({"error": "Fabric command timed out"}), 504 # Gateway Timeout
        except Exception as e:
            print(f"An unexpected error occurred: {e}")
            return jsonify({"error": f"An unexpected error occurred: {str(e)}"}), 500

    if __name__ == '__main__':
        # Run on 0.0.0.0 to be accessible within the container network
        # Railway will handle mapping the external port
        app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))

    