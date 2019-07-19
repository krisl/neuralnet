class Net
  def initialize topology
    @layers = topology.each_with_index.map do |neuron_count, i| 
      num_outputs = i == topology.count - 1 ? 0 : topology[i+1]
      Layer.new(neuron_count, num_outputs)
    end
  end

  def feed_forward input_vals
    puts "Feed forward"
    input_layer = @layers.first
    input_layer.set_output_values(input_vals)

    @layers.each_with_index do |layer, i|
      next if i == 0
      layer.feed_forward @layers[i - 1]
    end
  end

  def back_prop target_vals
    puts "Calc overall net errors"
    output_layer = @layers.last
    error = output_layer.neurons.each_with_index.sum do |neuron, i|
      delta = target_vals[i] - neuron.output
      delta * delta
    end

    error /= output_layer.size - 1
    @error = Math.sqrt error

    puts "output layer gradients"
    output_layer.each_with_index{|neuron, i| neuron.calc_output_gradient(target_vals[i])}

    puts "hidden layer grandients"
    @layers.reverse_each.with_index do |layer, i|
      next if layer == 0 || layer == @layers.size - 1 #skip output, input layers
      next_layer = @layers[i + 1]
      layer.neurons.each{|neuron| neuron.calc_hidden_gradient(next_layer)}
    end

    puts "update connection weights"
    @layers.reverse_each.with_index do |layer, i|
      next if layer == 0 || layer == @layers.size - 1 #skip output, input layers
      prev_layer = @layers[i - 1]
      layer.neurons.each_with_index{|neuron, i| neuron.update_input_weights(prev_layer, i)}
    end
  end

  def get_results
    output_layer = @layers.last
    output_layer.neurons.map{|neuron| neuron.output }
  end
end

class Layer
  attr_accessor :neurons

  def initialize neuron_count, num_outputs
    puts neuron_count
    @neurons = Array.new(neuron_count){ Neuron.new(num_outputs) }
  end

  def feed_forward prev_layer
    @neurons.each_with_index{|neuron, i| neuron.feed_forward(prev_layer, i)}
  end

  def set_output_values output_vals
    raise "invalid" if output_vals.size != @neurons.size
    @neurons.each_with_index{|neuron, i| neuron.set_output_value(output_vals[i])}
  end

  def size
    @neurons.size
  end

  def calc_dow connections
    @neurons.each_with_index.sum do |neuron, i|
      neuron.gradient * connections[i].weight
    end
  end
end

class Neuron
  attr_reader :output, :gradient
  @@eta = 0.15
  @@alpha = 0.5

  def initialize num_outputs
    puts "making a neuron with #{num_outputs} outputs"
    @connections = Array.new(num_outputs){ Connection.new }
    puts ""
  end

  def set_output_value value
    @output = value
  end

  def feed_forward prev_layer, i
    sum = prev_layer.neurons.reduce(0){|r, n| r += n.get_output_weighted_for(i) }
    @output = Neuron::transfer_function sum
  end

  def get_output_weighted_for i
    @output * @connections[i].weight
  end

  def self.transfer_function thing
    Math::tanh thing
  end

  def self.transfer_function_diriv thing
    1.0 - thing * thing
  end

  def calc_output_gradient target_val
    delta = target_val - @output
    @gradient = delta * Neuron::transfer_function_diriv(@output)
  end

  def calc_hidden_gradient next_layer
    dow = next_layer.dow connections
    @gradient = dow * Neuron::transfer_function(@output)
  end

  def get_output_delta_weight_for i
    @connections[i].delta_weight
  end

  def set_delta_weight delta, i
    @connections[i].delta_weight = delta
    @connections[i].weight += delta
  end

  def update_input_weights prev_layer, i
    prev_layer.neurons.each do |neuron|
      old_delta = neuron.get_output_delta_weight_for i
      new_delta = eta * neuron.output * @gradient * alpha * old_delta

      neuron.delta_weight(new_delta)
    end
  end
end

class Connection
  attr_accessor :weight, :delta_weight

  def initialize
    @weight = Random.new.rand
    puts "    Weight #{@weight}"
  end
end

topology = [3,2,1]
net = Net.new topology

input_vals = [1,1,1]
net.feed_forward input_vals

target_vals = []
net.back_prop target_vals

result_vals = net.get_results

puts result_vals

