#!/usr/bin/env python3
"""
CoSense Geofencing Analysis Tool
Análisis automatizado de optimizaciones tipo CoSense en geofencing
Simula las métricas reportadas en el paper CoSense
"""

import subprocess
import os
import time
import json
import re
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
import numpy as np
from typing import Dict, List, Tuple

class CoSenseGeofencingAnalyzer:
    def __init__(self, source_dir: str = "."):
        self.source_dir = Path(source_dir)
        self.results_dir = Path("cosense_analysis_results")
        self.results_dir.mkdir(exist_ok=True)
        
        # Archivos fuente
        self.generic_file = self.source_dir / "geofencing_generic.c"
        self.optimized_file = self.source_dir / "geofencing_optimized.c"
        self.comparison_file = self.source_dir / "geofencing_comparison.c"
        
        # Verificar archivos
        self._verify_files()
        
        # Resultados
        self.metrics = {}
        
    def _verify_files(self):
        """Verificar que los archivos fuente existen"""
        for file in [self.generic_file, self.optimized_file]:
            if not file.exists():
                raise FileNotFoundError(f"Archivo no encontrado: {file}")
        print("✅ Archivos fuente verificados")
    
    def compile_versions(self, optimization_levels: List[str] = ["O0", "O1", "O2", "O3"]) -> Dict:
        """Compilar todas las versiones con diferentes niveles de optimización"""
        print("🔨 Compilando versiones...")
        
        compilation_results = {}
        
        for opt_level in optimization_levels:
            print(f"  Compilando con -{opt_level}...")
            
            # Compilar versión genérica
            generic_binary = self.results_dir / f"generic_{opt_level}"
            generic_cmd = [
                "gcc", f"-{opt_level}", str(self.generic_file), 
                "-o", str(generic_binary), "-lm", "-g"
            ]
            
            # Medir tiempo de compilación
            start_time = time.time()
            result_generic = subprocess.run(generic_cmd, capture_output=True, text=True)
            generic_compile_time = time.time() - start_time
            
            # Compilar versión optimizada
            optimized_binary = self.results_dir / f"optimized_{opt_level}"
            optimized_cmd = [
                "gcc", f"-{opt_level}", str(self.optimized_file),
                "-o", str(optimized_binary), "-lm", "-g"
            ]
            
            start_time = time.time()
            result_optimized = subprocess.run(optimized_cmd, capture_output=True, text=True)
            optimized_compile_time = time.time() - start_time
            
            compilation_results[opt_level] = {
                'generic': {
                    'binary': generic_binary,
                    'compile_time': generic_compile_time,
                    'success': result_generic.returncode == 0,
                    'stderr': result_generic.stderr
                },
                'optimized': {
                    'binary': optimized_binary,
                    'compile_time': optimized_compile_time,
                    'success': result_optimized.returncode == 0,
                    'stderr': result_optimized.stderr
                }
            }
            
            if result_generic.returncode != 0:
                print(f"❌ Error compilando generic_{opt_level}: {result_generic.stderr}")
            if result_optimized.returncode != 0:
                print(f"❌ Error compilando optimized_{opt_level}: {result_optimized.stderr}")
        
        # Compilar comparison para validación
        if self.comparison_file.exists():
            comparison_binary = self.results_dir / "comparison"
            comparison_cmd = ["gcc", "-O2", str(self.comparison_file), "-o", str(comparison_binary), "-lm"]
            subprocess.run(comparison_cmd, capture_output=True, text=True)
        
        self.compilation_results = compilation_results
        print("✅ Compilación completada")
        return compilation_results
    
    def analyze_binary_sizes(self) -> Dict:
        """Analizar tamaños de binarios - métrica clave de CoSense"""
        print("📏 Analizando tamaños de binario...")
        
        size_results = {}
        
        for opt_level, binaries in self.compilation_results.items():
            if not binaries['generic']['success'] or not binaries['optimized']['success']:
                continue
                
            generic_binary = binaries['generic']['binary']
            optimized_binary = binaries['optimized']['binary']
            
            # Obtener tamaño de archivo
            generic_file_size = generic_binary.stat().st_size
            optimized_file_size = optimized_binary.stat().st_size
            
            # Usar 'size' command para análisis detallado
            try:
                generic_size = subprocess.run(
                    ["size", str(generic_binary)], 
                    capture_output=True, text=True, check=True
                )
                optimized_size = subprocess.run(
                    ["size", str(optimized_binary)],
                    capture_output=True, text=True, check=True
                )
                
                # Parsear output de size command
                generic_sections = self._parse_size_output(generic_size.stdout)
                optimized_sections = self._parse_size_output(optimized_size.stdout)
                
            except subprocess.CalledProcessError:
                # Fallback si 'size' no está disponible
                generic_sections = {'text': 0, 'data': 0, 'bss': 0, 'total': generic_file_size}
                optimized_sections = {'text': 0, 'data': 0, 'bss': 0, 'total': optimized_file_size}
            
            # Calcular reducción
            file_size_reduction = ((generic_file_size - optimized_file_size) / generic_file_size) * 100
            text_reduction = ((generic_sections['text'] - optimized_sections['text']) / 
                            max(generic_sections['text'], 1)) * 100
            
            size_results[opt_level] = {
                'generic_file_size': generic_file_size,
                'optimized_file_size': optimized_file_size,
                'file_size_reduction_percent': file_size_reduction,
                'generic_sections': generic_sections,
                'optimized_sections': optimized_sections,
                'text_reduction_percent': text_reduction
            }
        
        self.metrics['binary_sizes'] = size_results
        print("✅ Análisis de tamaños completado")
        return size_results
    
    def _parse_size_output(self, size_output: str) -> Dict:
        """Parsear output del comando 'size'"""
        lines = size_output.strip().split('\n')
        if len(lines) >= 2:
            values = lines[1].split()
            if len(values) >= 3:
                return {
                    'text': int(values[0]),
                    'data': int(values[1]),
                    'bss': int(values[2]),
                    'total': int(values[0]) + int(values[1]) + int(values[2])
                }
        return {'text': 0, 'data': 0, 'bss': 0, 'total': 0}
    
    def run_performance_benchmarks(self, iterations: int = 3) -> Dict:
        """Ejecutar benchmarks de rendimiento - métrica clave de CoSense"""
        print("⚡ Ejecutando benchmarks de rendimiento...")
        
        performance_results = {}
        
        for opt_level, binaries in self.compilation_results.items():
            if not binaries['generic']['success'] or not binaries['optimized']['success']:
                continue
                
            print(f"  Benchmarking {opt_level}...")
            
            generic_times = []
            optimized_times = []
            
            for i in range(iterations):
                # Benchmark versión genérica
                start_time = time.time()
                result_generic = subprocess.run(
                    [str(binaries['generic']['binary'])], 
                    capture_output=True, text=True
                )
                generic_time = time.time() - start_time
                generic_times.append(generic_time)
                
                # Benchmark versión optimizada
                start_time = time.time()
                result_optimized = subprocess.run(
                    [str(binaries['optimized']['binary'])],
                    capture_output=True, text=True
                )
                optimized_time = time.time() - start_time
                optimized_times.append(optimized_time)
                
                # Extraer métricas internas si están disponibles
                generic_ops = self._extract_ops_per_second(result_generic.stdout)
                optimized_ops = self._extract_ops_per_second(result_optimized.stdout)
            
            # Calcular estadísticas
            avg_generic_time = np.mean(generic_times)
            avg_optimized_time = np.mean(optimized_times)
            speedup = avg_generic_time / avg_optimized_time if avg_optimized_time > 0 else 1.0
            
            performance_results[opt_level] = {
                'generic_avg_time': avg_generic_time,
                'optimized_avg_time': avg_optimized_time,
                'speedup': speedup,
                'generic_times': generic_times,
                'optimized_times': optimized_times,
                'generic_ops_per_sec': generic_ops,
                'optimized_ops_per_sec': optimized_ops
            }
        
        self.metrics['performance'] = performance_results
        print("✅ Benchmarks de rendimiento completados")
        return performance_results
    
    def _extract_ops_per_second(self, output: str) -> float:
        """Extraer operaciones por segundo del output del programa"""
        # Buscar patrones como "Operaciones por segundo: 1234567"
        patterns = [
            r"Operaciones por segundo:\s*([\d,\.]+)",
            r"Operations per second:\s*([\d,\.]+)",
            r"ops/sec:\s*([\d,\.]+)"
        ]
        
        for pattern in patterns:
            match = re.search(pattern, output, re.IGNORECASE)
            if match:
                # Remover comas y convertir a float
                return float(match.group(1).replace(',', ''))
        return 0.0
    
    def analyze_assembly_code(self) -> Dict:
        """Analizar código assembly generado"""
        print("🔍 Analizando código assembly...")
        
        assembly_results = {}
        
        # Generar assembly para O2 (nivel de optimización típico)
        opt_level = "O2"
        
        # Assembly genérico
        generic_asm = self.results_dir / "generic_O2.s"
        subprocess.run([
            "gcc", "-S", "-O2", str(self.generic_file), "-o", str(generic_asm)
        ], capture_output=True)
        
        # Assembly optimizado
        optimized_asm = self.results_dir / "optimized_O2.s"
        subprocess.run([
            "gcc", "-S", "-O2", str(self.optimized_file), "-o", str(optimized_asm)
        ], capture_output=True)
        
        if generic_asm.exists() and optimized_asm.exists():
            # Contar líneas y instrucciones
            generic_stats = self._analyze_assembly_file(generic_asm)
            optimized_stats = self._analyze_assembly_file(optimized_asm)
            
            assembly_results = {
                'generic': generic_stats,
                'optimized': optimized_stats,
                'instruction_reduction': {
                    'total_lines': ((generic_stats['total_lines'] - optimized_stats['total_lines']) / 
                                  max(generic_stats['total_lines'], 1)) * 100,
                    'instructions': ((generic_stats['instructions'] - optimized_stats['instructions']) /
                                   max(generic_stats['instructions'], 1)) * 100
                }
            }
        
        self.metrics['assembly'] = assembly_results
        print("✅ Análisis de assembly completado")
        return assembly_results
    
    def _analyze_assembly_file(self, asm_file: Path) -> Dict:
        """Analizar un archivo de assembly"""
        with open(asm_file, 'r') as f:
            lines = f.readlines()
        
        total_lines = len(lines)
        instructions = 0
        branches = 0
        comparisons = 0
        function_calls = 0
        
        for line in lines:
            line = line.strip()
            if line and not line.startswith('.') and not line.startswith('#'):
                instructions += 1
                
                # Contar tipos de instrucciones específicas
                if any(branch in line for branch in ['jmp', 'je', 'jne', 'jl', 'jg', 'jle', 'jge']):
                    branches += 1
                if any(cmp in line for cmp in ['cmp', 'test']):
                    comparisons += 1
                if 'call' in line:
                    function_calls += 1
        
        return {
            'total_lines': total_lines,
            'instructions': instructions,
            'branches': branches,
            'comparisons': comparisons,
            'function_calls': function_calls
        }
    
    def run_comparison_validation(self) -> Dict:
        """Ejecutar el archivo comparison para validación cruzada"""
        print("🔄 Ejecutando validación con comparison...")
        
        comparison_binary = self.results_dir / "comparison"
        if not comparison_binary.exists():
            print("⚠️  Archivo comparison no compilado")
            return {}
        
        result = subprocess.run([str(comparison_binary)], capture_output=True, text=True)
        
        # Extraer métricas del output
        validation_results = {
            'output': result.stdout,
            'speedup_reported': self._extract_speedup_from_comparison(result.stdout),
            'memory_reduction': self._extract_memory_reduction(result.stdout)
        }
        
        self.metrics['validation'] = validation_results
        return validation_results
    
    def _extract_speedup_from_comparison(self, output: str) -> Dict:
        """Extraer speedup del output de comparison"""
        speedup_pattern = r"(\w+):\s*[\d\.]+ segundos \([\d\.]+ ops/sec\) \[([\d\.]+)x más rápido\]"
        matches = re.findall(speedup_pattern, output)
        
        speedups = {}
        for match in matches:
            version, speedup = match
            speedups[version] = float(speedup)
        
        return speedups
    
    def _extract_memory_reduction(self, output: str) -> Dict:
        """Extraer reducción de memoria del output"""
        reduction_pattern = r"Reducción de memoria:\s*([\d\.]+)%"
        matches = re.findall(reduction_pattern, output)
        
        if matches:
            return {'reduction_percent': float(matches[0])}
        return {}
    
    def generate_comprehensive_report(self):
        """Generar reporte visual completo"""
        print("📊 Generando reporte visual...")
        
        # Configurar estilo
        plt.style.use('seaborn-v0_8')
        sns.set_palette("husl")
        
        # Crear figura principal
        fig = plt.figure(figsize=(20, 12))
        
        # 1. Gráfico de Speedup
        ax1 = plt.subplot(2, 3, 1)
        self._plot_speedup(ax1)
        
        # 2. Gráfico de Reducción de Tamaño
        ax2 = plt.subplot(2, 3, 2)
        self._plot_size_reduction(ax2)
        
        # 3. Comparación de Tiempos de Compilación
        ax3 = plt.subplot(2, 3, 3)
        self._plot_compilation_times(ax3)
        
        # 4. Análisis de Assembly
        ax4 = plt.subplot(2, 3, 4)
        self._plot_assembly_analysis(ax4)
        
        # 5. Desglose por Nivel de Optimización
        ax5 = plt.subplot(2, 3, 5)
        self._plot_optimization_levels(ax5)
        
        # 6. Resumen de Métricas vs Paper CoSense
        ax6 = plt.subplot(2, 3, 6)
        self._plot_cosense_comparison(ax6)
        
        plt.tight_layout()
        plt.savefig(self.results_dir / 'cosense_geofencing_analysis.png', dpi=300, bbox_inches='tight')
        plt.show()
        
        # Generar reporte detallado
        self._generate_detailed_report()
    
    def _plot_speedup(self, ax):
        """Gráfico de speedup por nivel de optimización"""
        if 'performance' not in self.metrics:
            ax.text(0.5, 0.5, 'No performance data', ha='center', va='center')
            ax.set_title('Speedup Analysis')
            return
        
        opt_levels = list(self.metrics['performance'].keys())
        speedups = [self.metrics['performance'][level]['speedup'] for level in opt_levels]
        
        bars = ax.bar(opt_levels, speedups, color=['#ff7f0e', '#2ca02c', '#d62728', '#9467bd'])
        ax.axhline(y=1.0, color='black', linestyle='--', alpha=0.7, label='Baseline')
        ax.set_title('Execution Time Speedup\n(Higher is Better)', fontweight='bold')
        ax.set_ylabel('Speedup (×)')
        ax.set_xlabel('GCC Optimization Level')
        
        # Añadir valores en las barras
        for bar, speedup in zip(bars, speedups):
            height = bar.get_height()
            ax.text(bar.get_x() + bar.get_width()/2., height + 0.01,
                   f'{speedup:.2f}×', ha='center', va='bottom', fontweight='bold')
        
        # Línea de referencia del paper CoSense
        ax.axhline(y=1.18, color='red', linestyle=':', alpha=0.7, label='CoSense Min (1.18×)')
        ax.axhline(y=2.17, color='red', linestyle=':', alpha=0.7, label='CoSense Max (2.17×)')
        ax.legend()
    
    def _plot_size_reduction(self, ax):
        """Gráfico de reducción de tamaño binario"""
        if 'binary_sizes' not in self.metrics:
            ax.text(0.5, 0.5, 'No binary size data', ha='center', va='center')
            ax.set_title('Binary Size Reduction')
            return
        
        opt_levels = list(self.metrics['binary_sizes'].keys())
        reductions = [self.metrics['binary_sizes'][level]['file_size_reduction_percent'] 
                     for level in opt_levels]
        
        colors = ['green' if r > 0 else 'red' for r in reductions]
        bars = ax.bar(opt_levels, reductions, color=colors, alpha=0.7)
        ax.axhline(y=0, color='black', linestyle='-', alpha=0.5)
        ax.set_title('Binary Size Reduction\n(Higher is Better)', fontweight='bold')
        ax.set_ylabel('Size Reduction (%)')
        ax.set_xlabel('GCC Optimization Level')
        
        # Añadir valores en las barras
        for bar, reduction in zip(bars, reductions):
            height = bar.get_height()
            ax.text(bar.get_x() + bar.get_width()/2., height + (1 if height >= 0 else -1),
                   f'{reduction:.1f}%', ha='center', 
                   va='bottom' if height >= 0 else 'top', fontweight='bold')
        
        # Referencias del paper CoSense
        ax.axhline(y=10.95, color='orange', linestyle=':', alpha=0.7, label='CoSense ARM (10.95%)')
        ax.axhline(y=12.35, color='blue', linestyle=':', alpha=0.7, label='CoSense x86 (12.35%)')
        ax.legend()
    
    def _plot_compilation_times(self, ax):
        """Gráfico de tiempos de compilación"""
        if not hasattr(self, 'compilation_results'):
            ax.text(0.5, 0.5, 'No compilation data', ha='center', va='center')
            ax.set_title('Compilation Time')
            return
        
        opt_levels = list(self.compilation_results.keys())
        generic_times = [self.compilation_results[level]['generic']['compile_time'] 
                        for level in opt_levels]
        optimized_times = [self.compilation_results[level]['optimized']['compile_time']
                          for level in opt_levels]
        
        x = np.arange(len(opt_levels))
        width = 0.35
        
        ax.bar(x - width/2, generic_times, width, label='Generic', alpha=0.8)
        ax.bar(x + width/2, optimized_times, width, label='Optimized', alpha=0.8)
        
        ax.set_title('Compilation Time Comparison', fontweight='bold')
        ax.set_ylabel('Time (seconds)')
        ax.set_xlabel('GCC Optimization Level')
        ax.set_xticks(x)
        ax.set_xticklabels(opt_levels)
        ax.legend()
    
    def _plot_assembly_analysis(self, ax):
        """Gráfico de análisis de assembly"""
        if 'assembly' not in self.metrics or not self.metrics['assembly']:
            ax.text(0.5, 0.5, 'No assembly data', ha='center', va='center')
            ax.set_title('Assembly Analysis')
            return
        
        assembly = self.metrics['assembly']
        categories = ['Total Lines', 'Instructions', 'Branches', 'Comparisons']
        generic_values = [
            assembly['generic']['total_lines'],
            assembly['generic']['instructions'],
            assembly['generic']['branches'],
            assembly['generic']['comparisons']
        ]
        optimized_values = [
            assembly['optimized']['total_lines'],
            assembly['optimized']['instructions'],
            assembly['optimized']['branches'],
            assembly['optimized']['comparisons']
        ]
        
        x = np.arange(len(categories))
        width = 0.35
        
        ax.bar(x - width/2, generic_values, width, label='Generic', alpha=0.8)
        ax.bar(x + width/2, optimized_values, width, label='Optimized', alpha=0.8)
        
        ax.set_title('Assembly Code Analysis', fontweight='bold')
        ax.set_ylabel('Count')
        ax.set_xticks(x)
        ax.set_xticklabels(categories, rotation=45)
        ax.legend()
    
    def _plot_optimization_levels(self, ax):
        """Comparación de speedup vs reducción de tamaño"""
        if 'performance' not in self.metrics or 'binary_sizes' not in self.metrics:
            ax.text(0.5, 0.5, 'Insufficient data', ha='center', va='center')
            ax.set_title('Optimization Levels Comparison')
            return
        
        speedups = []
        size_reductions = []
        labels = []
        
        for level in self.metrics['performance']:
            if level in self.metrics['binary_sizes']:
                speedups.append(self.metrics['performance'][level]['speedup'])
                size_reductions.append(self.metrics['binary_sizes'][level]['file_size_reduction_percent'])
                labels.append(level)
        
        scatter = ax.scatter(speedups, size_reductions, s=100, alpha=0.7, c=range(len(labels)), cmap='viridis')
        
        for i, label in enumerate(labels):
            ax.annotate(label, (speedups[i], size_reductions[i]), 
                       xytext=(5, 5), textcoords='offset points')
        
        ax.set_xlabel('Speedup (×)')
        ax.set_ylabel('Size Reduction (%)')
        ax.set_title('Speedup vs Size Reduction\n(Top-right is optimal)', fontweight='bold')
        ax.grid(True, alpha=0.3)
    
    def _plot_cosense_comparison(self, ax):
        """Comparación con métricas del paper CoSense"""
        # Métricas promedio de nuestros resultados
        if 'performance' in self.metrics and 'binary_sizes' in self.metrics:
            our_speedup = np.mean([self.metrics['performance'][level]['speedup'] 
                                  for level in self.metrics['performance']])
            our_size_reduction = np.mean([self.metrics['binary_sizes'][level]['file_size_reduction_percent']
                                        for level in self.metrics['binary_sizes']])
        else:
            our_speedup = 1.0
            our_size_reduction = 0.0
        
        # Métricas del paper CoSense
        cosense_speedup_min = 1.18
        cosense_speedup_max = 2.17
        cosense_size_reduction_x86 = 12.35
        cosense_size_reduction_arm = 10.95
        
        categories = ['Speedup (×)', 'Size Reduction (%)']
        our_values = [our_speedup, our_size_reduction]
        cosense_min = [cosense_speedup_min, cosense_size_reduction_arm]
        cosense_max = [cosense_speedup_max, cosense_size_reduction_x86]
        
        x = np.arange(len(categories))
        width = 0.25
        
        ax.bar(x - width, our_values, width, label='Our Results', alpha=0.8, color='blue')
        ax.bar(x, cosense_min, width, label='CoSense Min', alpha=0.8, color='orange')
        ax.bar(x + width, cosense_max, width, label='CoSense Max', alpha=0.8, color='red')
        
        ax.set_title('Comparison with CoSense Paper', fontweight='bold')
        ax.set_xticks(x)
        ax.set_xticklabels(categories)
        ax.legend()
        
        # Añadir valores
        for i, (our, cmin, cmax) in enumerate(zip(our_values, cosense_min, cosense_max)):
            ax.text(i - width, our + 0.1, f'{our:.2f}', ha='center', va='bottom', fontweight='bold')
            ax.text(i, cmin + 0.1, f'{cmin:.2f}', ha='center', va='bottom', fontweight='bold')
            ax.text(i + width, cmax + 0.1, f'{cmax:.2f}', ha='center', va='bottom', fontweight='bold')
    
    def _generate_detailed_report(self):
        """Generar reporte detallado en texto"""
        report_file = self.results_dir / 'detailed_report.md'
        
        with open(report_file, 'w') as f:
            f.write("# CoSense-Style Geofencing Optimization Analysis\n\n")
            f.write("## Executive Summary\n\n")
            
            if 'performance' in self.metrics:
                avg_speedup = np.mean([self.metrics['performance'][level]['speedup'] 
                                     for level in self.metrics['performance']])
                f.write(f"- **Average Speedup**: {avg_speedup:.2f}×\n")
            
            if 'binary_sizes' in self.metrics:
                avg_size_reduction = np.mean([self.metrics['binary_sizes'][level]['file_size_reduction_percent']
                                            for level in self.metrics['binary_sizes']])
                f.write(f"- **Average Size Reduction**: {avg_size_reduction:.1f}%\n")
            
            f.write("\n## Detailed Results\n\n")
            f.write("### Performance Metrics\n\n")
            
            if 'performance' in self.metrics:
                for level, data in self.metrics['performance'].items():
                    f.write(f"**{level}**: {data['speedup']:.2f}× speedup\n")
            
            f.write("\n### Binary Size Analysis\n\n")
            
            if 'binary_sizes' in self.metrics:
                for level, data in self.metrics['binary_sizes'].items():
                    f.write(f"**{level}**: {data['file_size_reduction_percent']:.1f}% size reduction\n")
            
            f.write("\n### Comparison with CoSense Paper\n\n")
            f.write("| Metric | CoSense Paper | Our Results | Status |\n")
            f.write("|--------|---------------|-------------|--------|\n")
            
            if 'performance' in self.metrics:
                avg_speedup = np.mean([self.metrics['performance'][level]['speedup'] 
                                     for level in self.metrics['performance']])
                status = "✅" if 1.18 <= avg_speedup <= 2.17 else "❌"
                f.write(f"| Speedup | 1.18× - 2.17× | {avg_speedup:.2f}× | {status} |\n")
            
            if 'binary_sizes' in self.metrics:
                avg_size = np.mean([self.metrics['binary_sizes'][level]['file_size_reduction_percent']
                                  for level in self.metrics['binary_sizes']])
                status = "✅" if avg_size >= 10 else "❌"
                f.write(f"| Size Reduction | 10-15% | {avg_size:.1f}% | {status} |\n")
        
        print(f"✅ Reporte detallado guardado en: {report_file}")
    
    def run_full_analysis(self) -> Dict:
        """Ejecutar análisis completo"""
        print("🚀 Iniciando análisis completo CoSense-style...")
        
        try:
            # 1. Compilar versiones
            self.compile_versions()
            
            # 2. Analizar tamaños binarios
            self.analyze_binary_sizes()
            
            # 3. Ejecutar benchmarks de rendimiento
            self.run_performance_benchmarks()
            
            # 4. Analizar assembly
            self.analyze_assembly_code()
            
            # 5. Validación con comparison
            self.run_comparison_validation()
            
            # 6. Generar reporte visual
            self.generate_comprehensive_report()
            
            # 7. Guardar métricas en JSON
            metrics_file = self.results_dir / 'metrics.json'
            with open(metrics_file, 'w') as f:
                json.dump(self.metrics, f, indent=2, default=str)
            
            print("🎉 Análisis completo finalizado exitosamente!")
            print(f"📁 Resultados guardados en: {self.results_dir}")
            
            return self.metrics
            
        except Exception as e:
            print(f"❌ Error durante el análisis: {e}")
            raise

def main():
    """Función principal"""
    print("CoSense Geofencing Analysis Tool")
    print("================================")
    
    # Crear analizador
    analyzer = CoSenseGeofencingAnalyzer()
    
    # Ejecutar análisis completo
    results = analyzer.run_full_analysis()
    
    # Mostrar resumen
    if 'performance' in results:
        avg_speedup = np.mean([results['performance'][level]['speedup'] 
                              for level in results['performance']])
        print(f"\n📊 RESUMEN EJECUTIVO:")
        print(f"   Speedup promedio: {avg_speedup:.2f}×")
    
    if 'binary_sizes' in results:
        avg_reduction = np.mean([results['binary_sizes'][level]['file_size_reduction_percent']
                               for level in results['binary_sizes']])
        print(f"   Reducción de tamaño promedio: {avg_reduction:.1f}%")
    
    print(f"\n✅ Análisis tipo CoSense completado")

if __name__ == "__main__":
    main()