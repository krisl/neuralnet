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

  end

  def get_results

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
end

class Neuron
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
end

class Connection
  attr_accessor :weight

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

